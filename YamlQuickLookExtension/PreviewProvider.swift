import Foundation
import QuickLookUI
import UniformTypeIdentifiers
import OSLog

/// The main Quick Look preview provider for YAML files
@objc(PreviewProvider)
final class PreviewProvider: QLPreviewProvider, QLPreviewingController {
    private let logger = Logger(subsystem: "com.yamlquicklook.YamlQuickLook", category: "preview")

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        handler(nil)
    }

    func providePreview(for request: QLFilePreviewRequest, completionHandler handler: @escaping (QLPreviewReply?, Error?) -> Void) {
        let fileURL = request.fileURL
        
        do {
            // Read file content directly - simple plain text like .txt/.plist
            let yamlContent = try String(contentsOf: fileURL, encoding: .utf8)
            
            // Return plain text - this gives native scrollable Quick Look behavior
            let reply = QLPreviewReply(dataOfContentType: .plainText, contentSize: CGSize(width: 800, height: 600)) { _ in
                Data(yamlContent.utf8)
            }
            reply.stringEncoding = .utf8
            
            handler(reply, nil)
        } catch {
            logger.error("Failed to read YAML file: \(error.localizedDescription, privacy: .public)")
            handler(nil, error)
        }
    }
}
