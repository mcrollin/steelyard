//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import Console
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

    @Option(name: .shortAndLong, help: "Specify the destination path for the export JSON file.")
    public var output: String?

    public func run() async throws {
        Console.verbose = verbose
        let (app, sizesByBuildsAndVersions) = try await fetchAppSize()
        let data = AppSizeData(
            app: app,
            sizesByBuildAndVersions: sizesByBuildsAndVersions,
            includeDownloadSize: includeDownloadSize,
            includeInstallSize: includeInstallSize
        )
        let url = try await data.write(to: output)
        Console.success("Data successfully saved at: \(url.absoluteString)")
    }
}
