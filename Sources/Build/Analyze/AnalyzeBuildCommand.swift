//
//  Copyright © Marc Rollin.
//

import ApplicationArchive
import ArgumentParser
import CommandLine
import Foundation

// MARK: - AnalyzeBuildCommand

struct AnalyzeBuildCommand: AsyncParsableCommand {

    // MARK: Lifecycle

    init() { }

    // MARK: Internal

    static var configuration = CommandConfiguration(
        commandName: "analyze",
        abstract: "Perform a detailed analysis of an IPA file."
    )

    @Argument(help: "The file path to the IPA file to be analyzed.", transform: URL.init(fileURLWithPath:))
    var ipa: URL

    @OptionGroup var exportOptions: ExportOptions<GraphicExportFormat>
    @OptionGroup var consoleOptions: ConsoleOptions

    func validate() throws {
        guard FileManager.default.fileExists(atPath: ipa.path) else {
            throw ValidationError("Invalid filepath \(ipa.path)")
        }
    }

    func run() async throws {
        Console.configure(options: consoleOptions)

        print("\n\n===DUPLICATES===\n")
        try ApplicationArchive(at: ipa)
            .topLevelDuplicates
            .sorted(by: { $0.sizeInBytes > $1.sizeInBytes })
            .forEach { duplicate in
                print("---", duplicate.duplicateSizeInBytes.formattedBytes())
                duplicate.nodes.forEach { node in
                    print(node)
                }
            }
    }
}
