import AppKit
import OSLog
import QuickLookThumbnailing

final class ThumbnailProvider: QLThumbnailProvider {
    private let logger = Logger(subsystem: "com.yamlquicklook.YamlQuickLook", category: "thumbnail")
    private let renderer = YAMLPreviewRenderer.shared

    override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
        logger.debug("Generating thumbnail for \(request.fileURL.path, privacy: .public)")

        do {
            let output = try renderer.render(for: request.fileURL)
            let reply = makeThumbnailReply(for: request, output: output)
            handler(reply, nil)
        } catch {
            logger.error("Failed thumbnail render: \(error.localizedDescription, privacy: .public)")
            handler(nil, error)
        }
    }

    private func makeThumbnailReply(for request: QLFileThumbnailRequest, output: YAMLPreviewRenderOutput) -> QLThumbnailReply {
        let baseSize = max(request.maximumSize.width, request.maximumSize.height)
        let contextSize = CGSize(width: baseSize, height: baseSize)

        return QLThumbnailReply(contextSize: contextSize, currentContextDrawing: { [weak self] () -> Bool in
            guard let self, let context = NSGraphicsContext.current?.cgContext else { return false }
            self.drawThumbnail(in: context, size: contextSize, scale: request.scale, output: output)
            return true
        })
    }

    private func drawThumbnail(in context: CGContext, size: CGSize, scale: CGFloat, output: YAMLPreviewRenderOutput) {
        context.saveGState()
        defer { context.restoreGState() }

        context.scaleBy(x: scale, y: scale)

        let canvasSize = CGSize(width: size.width / scale, height: size.height / scale)
        let canvasRect = CGRect(origin: .zero, size: canvasSize)

        context.setFillColor(NSColor.windowBackgroundColor.cgColor)
        context.fill(canvasRect)

        NSGraphicsContext.saveGraphicsState()
        defer { NSGraphicsContext.restoreGraphicsState() }

        drawPlainPreview(in: canvasRect.insetBy(dx: 10, dy: 10), content: output.previewContent)
    }

    private func drawPlainPreview(in rect: CGRect, content: String) {
        let textRect = rect.insetBy(dx: 4, dy: 6)
        let snippet = makeSnippet(from: content)

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byTruncatingTail
        paragraph.lineSpacing = 1.5

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 9, weight: .regular),
            .foregroundColor: NSColor.labelColor,
            .paragraphStyle: paragraph
        ]

        NSAttributedString(string: snippet, attributes: attributes).draw(in: textRect)
    }

    private func makeSnippet(from content: String) -> String {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let lines = trimmed.split(separator: "\n", omittingEmptySubsequences: false)
        let maxLines = 60

        if lines.count <= maxLines {
            return trimmed
        }

        let prefix = lines.prefix(maxLines).joined(separator: "\n")
        return prefix + "\n…"
    }
}
