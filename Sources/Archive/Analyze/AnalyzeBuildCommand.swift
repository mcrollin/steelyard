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
        abstract: "Perform a detailed analysis of an app archive."
    )

    @Argument(help: "The file path to the .ipa or .app file.", transform: URL.init(fileURLWithPath:))
    var path: URL

    @OptionGroup var exportOptions: ExportOptions<GraphicExportFormat>
    @OptionGroup var consoleOptions: ConsoleOptions

    func validate() throws {
        guard FileManager.default.fileExists(atPath: path.path) else {
            throw ValidationError("Invalid filepath \(path.path)")
        }
    }

    func run() async throws {
        Console.configure(options: consoleOptions)

        print("\n\n===DUPLICATES===\n")
        try await Archive(from: path)
            .findTopLevelDuplicates()
            .forEach { duplicate in
                guard let first = duplicate.first else {
                    return
                }
                let potentialGain = first.sizeInBytes * (duplicate.count - 1)
                print("--- \(potentialGain.formattedBytes())")
                duplicate.forEach { node in
                    print(node)
                }
            }
    }
}
