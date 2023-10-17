//
//  Copyright © Marc Rollin.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

// MARK: - ViewRenderer

@MainActor
final class ViewRenderer<Content: View> {
    private let content: Content

    init(content: Content) {
        self.content = content
    }

    func renderImage() async -> CGImage? {
        let renderer = ImageRenderer(content: content)
        renderer.scale = 2

        return renderer.cgImage
    }
}

public extension View {

    func renderAsAnImage() async -> CGImage? {
        await ViewRenderer(content: self).renderImage()
    }

    func saveAsAnImage(filePath: URL? = nil) async -> URL? {
        guard let image = await renderAsAnImage() else {
            return nil
        }

        let url = filePath ?? FileManager.default
            .temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("png")

        let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }

        return url
    }
}
