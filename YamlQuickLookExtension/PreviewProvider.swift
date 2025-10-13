import Foundation
import QuickLookUI
import UniformTypeIdentifiers
import OSLog

/// The main Quick Look preview provider for YAML files
@objc(PreviewProvider)
final class PreviewProvider: QLPreviewProvider, QLPreviewingController {
    private let logger = Logger(subsystem: "com.yamlquicklook.YamlQuickLook", category: "preview")
    private let renderer = YAMLPreviewRenderer.shared

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        logger.debug("Preparing preview for \(url.path, privacy: .public)")
        handler(nil)
    }

    func providePreview(for request: QLFilePreviewRequest, completionHandler handler: @escaping (QLPreviewReply?, Error?) -> Void) {
        let fileURL = request.fileURL
        logger.info("Rendering YAML preview for \(fileURL.path, privacy: .public)")

        do {
            let output = try renderer.render(for: fileURL)
            let html = output.html

            let reply = QLPreviewReply(dataOfContentType: .html, contentSize: CGSize(width: 1024, height: 768)) { _ in
                Data(html.utf8)
            }
            reply.stringEncoding = String.Encoding.utf8

            handler(reply, nil)
            logger.debug("Delivered preview reply for \(fileURL.lastPathComponent, privacy: .public)")
        } catch {
            logger.error("Failed to render preview: \(error.localizedDescription, privacy: .public)")
            handler(nil, error)
        }
    }
}