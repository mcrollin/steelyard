//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import Foundation
import Platform

// MARK: - DataCommand

public struct DataCommand: AsyncParsableCommand, AppSizeFetcher {

    // MARK: Lifecycle

    public init() { }

    // MARK: Public

    public static var configuration = CommandConfiguration(
        commandName: "data",
        abstract: "Produce a JSON file with in-depth size metrics for a specific app."
    )

    @OptionGroup public var appStoreConnectArguments: AppStoreConnectArguments
    @OptionGroup public var fetchOptions: FetchOptions
    @OptionGroup public var exportOptions: ExportOptions
    @OptionGroup public var runOptions: RunOptions

    public func run() async throws {
        Console.verbose = runOptions.verbose
        let (app, buildsSizes) = try await fetchAppSize()
        let data = AppSizeData(
            app: app,
            buildsSizes: buildsSizes,
            includeDownloadSize: exportOptions.includeDownloadSize,
            includeInstallSize: exportOptions.includeInstallSize
        )
        let url = try await data.write(to: exportOptions.output)
        Console.success("Data successfully saved at: \(url.absoluteString)")
    }
}
