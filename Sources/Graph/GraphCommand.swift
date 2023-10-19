//
//  Copyright © Marc Rollin.
//

import AppSizeFetcher
import ArgumentParser
import Console
import Foundation
import Platform
import ViewRenderer

// MARK: - Steelyard

public struct GraphCommand: AsyncParsableCommand {

    @Argument(help: "The key ID from the Apple Developer portal.")
    public var keyID: String

    @Argument(help: "The issuer ID from the App Store Connect organization.")
    public var issuerID: String

    @Argument(help: "The path to the .p8 private key file.")
    public var privateKeyPath: String

    @Argument(help: "The App ID.")
    public var appID: String

    @Flag(help: "Fetch sizes categorized by version, not build. Slower to retrieve.")
    public var byVersion = false

    @Flag(name: .customLong("download-size"), inversion: .prefixedNo, help: "Process bundle download sizes.")
    public var includeDownloadSize = true

    @Flag(name: .customLong("install-size"), inversion: .prefixedNo, help: "Process bundle install sizes.")
    public var includeInstallSize = true

    @Flag(name: .shortAndLong, help: "Display all information messages.")
    public var verbose = false

    @Option(name: .shortAndLong, help: "Specify the destination path for the generated PNG file.")
    public var output: String?

    @Option(name: .shortAndLong, help: "The number of builds to process, between 0 and 200.")
    public var limit = 30

    @Option(help: "The reference device to highlight in the charts.")
    public var referenceDeviceIdentifier = "iPhone12,1"

    public static var configuration = CommandConfiguration(
        commandName: "graph",
        abstract: "Generate graphs for download and install app sizes."
    )

    public init() {}

    public mutating func validate() throws {
        limit = limit.clamped(to: 0...200)
    }

    public func run() async throws {
        Console.verbose = verbose

        do {
            let (app, sizesByBuildsAndVersions) = try await AppSizeFetcher(
                keyID: keyID,
                issuerID: issuerID,
                privateKeyPath: privateKeyPath
            ).fetch(
                appID: appID,
                byVersion: byVersion,
                limit: limit,
                verbose: verbose
            )

            var filePath: URL?
            if let output {
                filePath = URL(fileURLWithPath: output)
            }

            if let url = await Dashboard(
                model: .init(
                    app: app,
                    sizesByBuildsAndVersions: sizesByBuildsAndVersions,
                    includeDownloadSize: includeDownloadSize,
                    includeInstallSize: includeInstallSize,
                    referenceDeviceIdentifier: referenceDeviceIdentifier
                )
            ).saveAsAnImage(filePath: filePath) {
                Console.success("Chart generated successfully! Saved at: \(url.absoluteString)")
            }
        } catch let error as CustomStringConvertible {
            Console.error(error.description)
        } catch {
            Console.error(error.localizedDescription)
        }
    }
}
