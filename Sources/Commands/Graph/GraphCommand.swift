//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import Foundation
import Platform
import UI

public struct GraphCommand: AsyncParsableCommand, AppSizeFetcher {

    // MARK: Lifecycle

    public init() { }

    // MARK: Public

    public static var configuration = CommandConfiguration(
        commandName: "graph",
        abstract: "Create a PNG image that displays historical size graphs for a specific app."
    )

    @OptionGroup public var appStoreConnectArguments: AppStoreConnectArguments
    @OptionGroup public var fetchOptions: FetchOptions
    @OptionGroup public var exportOptions: ExportOptions
    @OptionGroup public var runOptions: RunOptions

    @Flag(help: "Set to dark color scheme.")
    public var darkScheme = false

    @Option(help: "The reference device to highlight in the charts.")
    public var referenceDeviceIdentifier = "iPhone12,1"

    public func run() async throws {
        Console.verbose = runOptions.verbose
        let (app, sizesByBuildsAndVersions) = try await fetchAppSize()
        let dashboard = Dashboard(
            model: .init(
                app: app,
                sizesByBuildsAndVersions: sizesByBuildsAndVersions,
                includeDownloadSize: exportOptions.includeDownloadSize,
                includeInstallSize: exportOptions.includeInstallSize,
                referenceDeviceIdentifier: referenceDeviceIdentifier,
                darkScheme: darkScheme
            )
        )
        let url = try await dashboard.renderImage(to: exportOptions.output)
        Console.success("Image successfully saved at: \(url.absoluteString)")
    }
}
