//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import CommandLine
import Foundation
import Platform
import SwiftUI

struct GraphHistoryCommand: AsyncParsableCommand, BuildSizeHistoryFetcher {

    // MARK: Lifecycle

    init() { }

    // MARK: Internal

    static var configuration = CommandConfiguration(
        commandName: "graph",
        abstract: "Create a graph of sizes by version or build for a specific app."
    )

    @OptionGroup var appStoreConnectArguments: AppStoreConnectArguments
    @OptionGroup var fetchOptions: FetchOptions
    @OptionGroup var sizeOptions: SizeOptions
    @OptionGroup var exportOptions: ExportOptions<GraphicExportFormat>
    @OptionGroup var consoleOptions: ConsoleOptions
    @OptionGroup var themeOptions: ThemeOptions

    @Option(help: "The reference device to highlight in the charts.")
    var referenceDeviceIdentifier = "iPhone12,1"

    func run() async throws {
        Console.configure(options: consoleOptions)
        let history = try await fetchHistory()
        let dashboard = Dashboard(
            model: .init(
                app: history.app,
                buildsSizes: history.sizes,
                includeDownloadSize: sizeOptions.includeDownloadSize,
                includeInstallSize: sizeOptions.includeInstallSize,
                referenceDeviceIdentifier: referenceDeviceIdentifier
            )
        ).colorScheme(themeOptions.colorScheme)

        let url: URL = switch exportOptions.format {
        case .pdf: try await dashboard.savePDF(to: exportOptions.output)
        case .png: try await dashboard.saveImage(to: exportOptions.output)
        }
        Console.success("Graph \(exportOptions.format.rawValue.uppercased()) file saved at: \(url.absoluteString)")
    }
}
