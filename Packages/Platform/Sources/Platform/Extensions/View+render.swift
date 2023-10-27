//
//  Copyright © Marc Rollin.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - ViewRenderer

@MainActor
private final class ViewRenderer<Content: View> {

    // MARK: Lifecycle

    init(content: Content) {
        self.content = content
    }

    // MARK: Internal

    var imageRenderer: ImageRenderer<Content> {
        get async {
            ImageRenderer(content: content)..{
                $0.scale = NSScreen.main?.backingScaleFactor ?? 3
            }
        }
    }

    // MARK: Private

    private let content: Content
}

// MARK: - RenderingError

public enum RenderingError: Error, CustomStringConvertible {
    case viewRender
    case diskWrite(url: URL)

    public var description: String {
        switch self {
        case .viewRender:
            "Could not render view"
        case .diskWrite(let url):
            "Could not write to disk at path \(url.absoluteString)"
        }
    }
}

@MainActor
extension View {

    // MARK: Public

    public func renderImage(atSize size: CGSize? = nil) async throws -> CGImage {
        guard let image = await ViewRenderer(content: resized(to: size)).imageRenderer.cgImage else {
            throw RenderingError.viewRender
        }

        return image
    }

    public func saveImage(to url: URL? = nil, atSize size: CGSize? = nil) async throws -> URL {
        try await fileURL(from: url, withExtension: "png")..{
            guard let destination = CGImageDestinationCreateWithURL($0 as CFURL, UTType.png.identifier as CFString, 1, nil) else {
                throw RenderingError.diskWrite(url: $0)
            }
            CGImageDestinationAddImage(destination, try await renderImage(atSize: size), nil)
            guard CGImageDestinationFinalize(destination) else {
                throw RenderingError.diskWrite(url: $0)
            }
        }
    }

    public func savePDF(to url: URL? = nil, atSize size: CGSize? = nil) async throws -> URL {
        try await fileURL(from: url, withExtension: "pdf")..{ url in
            await ViewRenderer(content: resized(to: size)).imageRenderer..{ renderer in
                renderer.render { size, context in
                    var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)

                    guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
                        return
                    }

                    pdf.beginPDFPage(nil)
                    context(pdf)
                    pdf.endPDFPage()
                    pdf.closePDF()
                }
            }
        }
    }

    // MARK: Private

    private func fileURL(from url: URL?, withExtension extension: String) -> URL {
        url ?? FileManager.default
            .temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(`extension`)
    }

}

extension View {

    private func resized(to size: CGSize?) -> some View {
        if let size {
            AnyView(frame(width: size.width, height: size.height))
        } else {
            AnyView(self)
        }
    }
}
