//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import Console
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

    @Argument(help: Self.keyIDArgumentHelp)
    public var keyID: String

    @Argument(help: Self.issuerIDArgumentHelp)
    public var issuerID: String

    @Argument(help: Self.privateKeyPathArgumentHelp)
    public var privateKeyPath: String

    @Argument(help: Self.appIDArgumentHelp)
    public var appID: String

    @Flag(name: .shortAndLong, help: Self.verboseArtgumentHelp)
    public var verbose = false

    @Flag(help: Self.byVersionArgumentHelp)
    public var byVersion = false

    @Option(name: .shortAndLong, help: Self.limitArgumentHelp)
    public var limit = 30

    @Flag(name: .customLong("download-size"), inversion: .prefixedNo, help: Self.includeDownloadSizeHelp)
    public var includeDownloadSize = true

    @Flag(name: .customLong("install-size"), inversion: .prefixedNo, help: Self.includeInstallSizeHelp)
    public var includeInstallSize = true

    @Option(help: "The reference device to highlight in the charts.")
    public var referenceDeviceIdentifier = "iPhone12,1"

    @Option(name: .shortAndLong, help: "Specify the destination path for the generated PNG file.")
    public var output: String?

    public func run() async throws {
        Console.verbose = verbose
        let (app, sizesByBuildsAndVersions) = try await fetchAppSize()
        let dashboard = Dashboard(
            model: .init(
                app: app,
                sizesByBuildsAndVersions: sizesByBuildsAndVersions,
                includeDownloadSize: includeDownloadSize,
                includeInstallSize: includeInstallSize,
                referenceDeviceIdentifier: referenceDeviceIdentifier
            )
        )
        let url = try await dashboard.renderImage(to: output)
        Console.success("Image successfully saved at: \(url.absoluteString)")
    }
}
