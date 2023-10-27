//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import CommandLine
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
        abstract: "Display a detailed inspection of an IPA file to assess its size and components."
    )

    @Argument(help: "The file path to the IPA file to be inspected.", transform: URL.init(fileURLWithPath:))
    var ipa: URL

    @OptionGroup var exportOptions: ExportOptions<GraphicExportFormat>
    @OptionGroup var runOptions: RunOptions
    @OptionGroup var consoleOptions: ConsoleOptions
    @OptionGroup var themeOptions: ThemeOptions

    func validate() throws {
        guard FileManager.default.fileExists(atPath: ipa.path) else {
            throw ValidationError("Invalid filepath \(ipa.path)")
        }
    }

    func run() async throws {
        Console.configure(options: consoleOptions)

        let inspectCoordinator = try InspectView(inspector: .init(tree: .init(at: ipa)))
            .colorScheme(themeOptions.colorScheme)

        if runOptions.interactive {
            let task = autoreleasepool {
                Task { @MainActor in
                    NSApplication.shared.run {
                        inspectCoordinator
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            await task.value
        } else {
            let inspectCoordinator = inspectCoordinator.frame(width: 3840, height: 2160)
            let url: URL = switch exportOptions.format {
            case .pdf: try await inspectCoordinator.savePDF(to: exportOptions.output)
            case .png: try await inspectCoordinator.saveImage(to: exportOptions.output)
            }

            Console.success("Inspect \(exportOptions.format.rawValue.uppercased()) file saved at: \(url.absoluteString)")
        }
    }

}
