import Foundation
import OSLog
import Yams

public struct YAMLPreviewRenderOutput {
    public let html: String
    public let fileInfo: FileInfo
    public let analysis: YAMLAnalysis
    public let previewContent: String

    public struct FileInfo {
        public let fileName: String
        public let sizeDescription: String?
        public let modificationDate: String?
        public let lineCount: Int
        public let characterCount: Int
    }

    public struct YAMLStatistics {
        public let rootType: String
        public let keyCount: Int
        public let sequenceCount: Int
        public let scalarCount: Int
        public let nullCount: Int
        public let maxDepth: Int
        public let topLevelKeys: [String]
    }

    public struct YAMLAnalysis {
        public let stats: YAMLStatistics?
        public let validationError: String?
        public let truncated: Bool
    }
}

public final class YAMLPreviewRenderer {
    public static let shared = YAMLPreviewRenderer()

    private let byteFormatter: ByteCountFormatter
    private let dateFormatter: DateFormatter
    private let logger = Logger(subsystem: "com.yamlquicklook.YamlQuickLook", category: "generator")

    /// Hard cap of characters rendered inside the preview to keep large files responsive.
    private let maxRenderableCharacters = 250_000

    private init() {
        byteFormatter = ByteCountFormatter()
        byteFormatter.allowedUnits = [.useKB, .useMB]
        byteFormatter.countStyle = .file

        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
    }

    public func render(for fileURL: URL) throws -> YAMLPreviewRenderOutput {
        let data = try Data(contentsOf: fileURL)
        let content = String(decoding: data, as: UTF8.self)
        return try render(for: fileURL, originalContent: content)
    }

    public func render(for fileURL: URL, originalContent: String) throws -> YAMLPreviewRenderOutput {
        let fileInfo = buildFileInfo(for: fileURL, content: originalContent)
        let analysis = analyze(content: originalContent)

        let previewContent: String
        if originalContent.count > maxRenderableCharacters {
            let index = originalContent.index(originalContent.startIndex, offsetBy: maxRenderableCharacters)
            previewContent = String(originalContent[..<index])
        } else {
            previewContent = originalContent
        }

        let escapedTitle = fileInfo.fileName.htmlEscaped()
        let escapedContent = previewContent.htmlEscaped()

        let metadataComments: String = {
            var lines: [String] = []
            if let errorMessage = analysis.validationError {
                lines.append("<!-- YAML parse error: \(errorMessage.htmlCommentEscaped()) -->")
            }
            if analysis.truncated {
                lines.append("<!-- Preview truncated at \(maxRenderableCharacters.formatted()) characters -->")
            }
            if previewContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                lines.append("<!-- YAML file is empty -->")
            }
            guard !lines.isEmpty else { return "" }
            return lines.joined(separator: "\n") + "\n"
        }()

        let html = """
        <!DOCTYPE html>
        <html lang=\"en\">
        <head>
            <meta charset=\"utf-8\">
            <title>YAML Preview – \(escapedTitle)</title>
            \(Self.htmlStyleBlock)
        </head>
        <body>
            \(metadataComments)<pre>\(escapedContent)</pre>
        </body>
        </html>
        """

        let output = YAMLPreviewRenderOutput(
            html: html,
            fileInfo: fileInfo,
            analysis: analysis,
            previewContent: previewContent
        )

        return output
    }

    private func analyze(content: String) -> YAMLPreviewRenderOutput.YAMLAnalysis {
        do {
            guard let decoded = try Yams.load(yaml: content) else {
                logger.debug("YAML document is empty")
                return YAMLPreviewRenderOutput.YAMLAnalysis(stats: nil, validationError: nil, truncated: content.count > maxRenderableCharacters)
            }

            var builder = StatsBuilder()
            builder.walk(value: decoded, depth: 1)

            let rootType = builder.rootTypeDescription(for: decoded)
            let topLevelKeys = builder.topLevelKeys(from: decoded)

            let stats = YAMLPreviewRenderOutput.YAMLStatistics(
                rootType: rootType,
                keyCount: builder.keyCount,
                sequenceCount: builder.sequenceCount,
                scalarCount: builder.scalarCount,
                nullCount: builder.nullCount,
                maxDepth: builder.maxDepth,
                topLevelKeys: topLevelKeys
            )

            return YAMLPreviewRenderOutput.YAMLAnalysis(stats: stats, validationError: nil, truncated: content.count > maxRenderableCharacters)
        } catch {
            logger.error("Parsing failed: \(error.localizedDescription, privacy: .public)")
            return YAMLPreviewRenderOutput.YAMLAnalysis(stats: nil, validationError: error.localizedDescription, truncated: content.count > maxRenderableCharacters)
        }
    }

    private func buildFileInfo(for url: URL, content: String) -> YAMLPreviewRenderOutput.FileInfo {
        var sizeDescription: String? = nil
        var modificationDate: String? = nil

        if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) {
            if let size = attributes[.size] as? NSNumber {
                sizeDescription = byteFormatter.string(fromByteCount: size.int64Value)
            }
            if let date = attributes[.modificationDate] as? Date {
                modificationDate = dateFormatter.string(from: date)
            }
        }

        let newlineCount = content.reduce(into: 0) { partial, character in
            if character == "\n" { partial += 1 }
        }
        let lineCount = content.isEmpty ? 0 : newlineCount + 1

        return YAMLPreviewRenderOutput.FileInfo(
            fileName: url.lastPathComponent,
            sizeDescription: sizeDescription,
            modificationDate: modificationDate,
            lineCount: lineCount,
            characterCount: content.count
        )
    }

    private static let htmlStyleBlock = """
            <style>
                :root { color-scheme: light dark; }
                * { box-sizing: border-box; }
                html { background: transparent; }
                body {
                    margin: 0;
                    padding: 0;
                    background: transparent;
                    color: canvastext;
                    font-family: "SFMono-Regular", Menlo, Consolas, monospace;
                    font-size: 13px;
                    line-height: 1.5;
                }
                pre {
                    margin: 0;
                    padding: 16px 20px;
                    font: inherit;
                    white-space: pre;
                    color: inherit;
                    background: transparent;
                }
            </style>
    """
}

// MARK: - Helpers (StatsBuilder, Extensions)

private struct StatsBuilder {
    var keyCount = 0
    var sequenceCount = 0
    var scalarCount = 0
    var nullCount = 0
    var maxDepth = 0

    mutating func walk(value: Any, depth: Int) {
        maxDepth = max(maxDepth, depth)

        switch value {
        case let dict as [String: Any]:
            keyCount += dict.keys.count
            for child in dict.values {
                walk(value: child, depth: depth + 1)
            }
        case let array as [Any]:
            sequenceCount += 1
            for child in array {
                walk(value: child, depth: depth + 1)
            }
        case is NSNull:
            nullCount += 1
        default:
            scalarCount += 1
        }
    }

    func rootTypeDescription(for value: Any) -> String {
        switch value {
        case is [String: Any]: return "Mapping"
        case is [Any]: return "Sequence"
        case is NSNull: return "Null"
        default: return "Scalar"
        }
    }

    func topLevelKeys(from value: Any) -> [String] {
        guard let dict = value as? [String: Any] else { return [] }
        return dict.keys.sorted()
    }
}

private extension String {
    func htmlEscaped() -> String {
        var escaped = self
        let replacements: [String: String] = [
            "&": "&amp;",
            "<": "&lt;",
            ">": "&gt;",
            "\"": "&quot;",
            "'": "&#39;"
        ]
        for (key, value) in replacements {
            escaped = escaped.replacingOccurrences(of: key, with: value)
        }
        return escaped
    }

    func htmlCommentEscaped() -> String {
        htmlEscaped().replacingOccurrences(of: "--", with: "—")
    }
}
