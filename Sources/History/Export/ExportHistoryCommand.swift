//
//  Copyright © Marc Rollin.
//

import AppStoreConnect
import ArgumentParser
import CommandLine
import Foundation
import Platform

// MARK: - DataCommand

struct ExportHistoryCommand: AsyncParsableCommand, BuildSizeHistoryFetcher {

    // MARK: Lifecycle

    init() { }

    // MARK: Internal

    static var configuration = CommandConfiguration(
        commandName: "export",
        abstract: "Export in-depth size metrics for a specific app."
    )

    @OptionGroup var appStoreConnectArguments: AppStoreConnectArguments
    @OptionGroup var fetchOptions: FetchOptions
    @OptionGroup var sizeOptions: SizeOptions
    @OptionGroup var exportOptions: ExportOptions<GraphicExportFormat>
    @OptionGroup var consoleOptions: ConsoleOptions

    func run() async throws {
        Console.configure(options: consoleOptions)
        let history = try await fetchHistory()
        let data = AppSizeData(
            app: history.app,
            buildsSizes: history.sizes,
            includeDownloadSize: sizeOptions.includeDownloadSize,
            includeInstallSize: sizeOptions.includeInstallSize
        )
        let url = try await data.write(to: exportOptions.output)
        Console.success("Export \(exportOptions.format.rawValue.uppercased()) file saved at: \(url.absoluteString)")
    }
}
