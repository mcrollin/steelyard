//
//  Copyright © Marc Rollin.
//

import ApplicationArchive
import ArgumentParser
import CommandLine
import DesignComponents
import Foundation
import Platform
import SwiftUI

// MARK: - InspectBuildCommand

struct InspectBuildCommand: AsyncParsableCommand {

    // MARK: Lifecycle

    init() { }

    // MARK: Internal

    static var configuration = CommandConfiguration(
        commandName: "inspect",
        abstract: "Display a detailed size inspection of app archive."
    )

    @Argument(help: "The file path to the .ipa or .app file.", transform: URL.init(fileURLWithPath:))
    var path: URL

    @OptionGroup var exportOptions: ExportOptions<GraphicExportFormat>
    @OptionGroup var consoleOptions: ConsoleOptions
    @OptionGroup var themeOptions: ThemeOptions

    func validate() throws {
        guard FileManager.default.fileExists(atPath: path.path) else {
            throw ValidationError("Invalid filepath \(path.path)")
        }
    }

    func run() async throws {
        Console.configure(options: consoleOptions)

        let archive = try await Archive(from: path)
        let treeMap = TreeMap(node: archive.root, duplicates: archive.duplicateIDs)
            .colorScheme(themeOptions.colorScheme)
            .frame(width: 3840, height: 2160)

        let url: URL = switch exportOptions.format {
        case .pdf: try await treeMap.savePDF(to: exportOptions.output)
        case .png: try await treeMap.saveImage(to: exportOptions.output)
        }

        Console.success("Inspect \(exportOptions.format.rawValue.uppercased()) file saved at: \(url.absoluteString)")
    }

}
