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

    func renderImage() async -> CGImage? {
        let renderer = ImageRenderer(content: content)
        renderer.scale = 2

        return renderer.cgImage
    }

    // MARK: Private

    private let content: Content

}

// MARK: - RenderingError

public enum RenderingError: Error, CustomStringConvertible {
    case imageRender
    case diskWrite(url: URL)

    public var description: String {
        switch self {
        case .imageRender:
            "Could not render image"
        case .diskWrite(let url):
            "Could not write to disk at path \(url.absoluteString)"
        }
    }
}

extension View {

    public func renderImage() async throws -> CGImage {
        guard let image = await ViewRenderer(content: self).renderImage() else {
            throw RenderingError.imageRender
        }

        return image
    }

    public func renderImage(to filePath: String? = nil) async throws -> URL {
        let image = try await renderImage()

        let url: URL
        if let filePath {
            url = URL(fileURLWithPath: filePath)
        } else {
            url = FileManager.default
                .temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("png")
        }

        let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            throw RenderingError.diskWrite(url: url)
        }

        return url
    }
}
