//
//  Copyright © Marc Rollin.
//

import AppStoreConnect
import ArgumentParser
import Console
import Foundation

// MARK: - AppSizeFetcher

public protocol AppSizeFetcher {
    static var limitArgumentHelp: ArgumentHelp { get }
    static var keyIDArgumentHelp: ArgumentHelp { get }
    static var issuerIDArgumentHelp: ArgumentHelp { get }
    static var privateKeyPathArgumentHelp: ArgumentHelp { get }
    static var appIDArgumentHelp: ArgumentHelp { get }
    static var byVersionArgumentHelp: ArgumentHelp { get }
    static var verboseArtgumentHelp: ArgumentHelp { get }
    static var includeDownloadSizeHelp: ArgumentHelp { get }
    static var includeInstallSizeHelp: ArgumentHelp { get }

    var keyID: String { get }
    var issuerID: String { get }
    var privateKeyPath: String { get }
    var appID: String { get }
    var byVersion: Bool { get }
    var limit: Int { get }
    var verbose: Bool { get }
    var includeDownloadSize: Bool { get }
    var includeInstallSize: Bool { get }
    var output: String? { get }

    func fetchAppSize() async throws -> (Application, [SizesByBuildAndVersion])
}

extension AppSizeFetcher {

    // MARK: Public

    public static var limitArgumentHelp: ArgumentHelp {
        """
        Specify the number of items to analyze.
        - For builds, the range is \(Self.buildsRangeLimit.lowerBound) to \(Self.buildsRangeLimit.upperBound) to 200.
        - For versions, the range is \(Self.versionsRangeLimit.lowerBound) to \(Self.versionsRangeLimit.upperBound).
        """
    }

    public static var keyIDArgumentHelp: ArgumentHelp { "The key ID from the Apple Developer portal." }
    public static var issuerIDArgumentHelp: ArgumentHelp { "The issuer ID from the App Store Connect organization." }
    public static var privateKeyPathArgumentHelp: ArgumentHelp { "The path to the .p8 private key file." }
    public static var appIDArgumentHelp: ArgumentHelp { "The App ID." }
    public static var byVersionArgumentHelp: ArgumentHelp { "Fetch sizes categorized by version, not build. Slower to retrieve." }
    public static var verboseArtgumentHelp: ArgumentHelp { "Display all information messages." }
    public static var includeDownloadSizeHelp: ArgumentHelp { "Include download sizes." }
    public static var includeInstallSizeHelp: ArgumentHelp { "Include install sizes." }

    public func fetchAppSize() async throws -> (Application, [SizesByBuildAndVersion]) {
        let appStoreConnect: AppStoreConnect = try AppStoreConnect(
            keyID: keyID,
            issuerID: issuerID,
            privateKeyPath: privateKeyPath
        )

        let app = try await appStoreConnect.app(appID: appID)
        Console.info("Successfully identified app with ID \(appID): \"\(app.name)\"")

        let sizesByBuildsAndVersions: [SizesByBuildAndVersion]

        if byVersion {
            Console.debug("Fetching \(limit) most recent versions…")
            let versions = try await appStoreConnect.versions(app: app, limit: limit)
            Console.info("Retrieved \(versions.count) most recent versions (maximum limit set to \(limit))")

            Console.debug("")
            sizesByBuildsAndVersions = try await appStoreConnect.sizes(versions: versions) { progress in
                Console.debug(
                    "Fetching individual version sizes… \(Console.progress(progress, columns: 40))",
                    prefix: "\u{1B}[1A\u{1B}[K"
                )
            }
            Console.info("Fetched file sizes for \(sizesByBuildsAndVersions.count) builds")
        } else {
            Console.debug("Fetching \(limit) most recent builds…")
            let builds = try await appStoreConnect.builds(app: app, limit: limit)
            Console.info("Retrieved \(builds.count) most recent builds (maximum limit set to \(limit))")

            Console.debug("")
            sizesByBuildsAndVersions = try await appStoreConnect.sizes(builds: builds) { progress in
                Console.debug(
                    "Fetching individual build sizes… \(Console.progress(progress, columns: 40))",
                    prefix: "\u{1B}[1A\u{1B}[K"
                )
            }
            Console.info("Fetched file sizes for \(sizesByBuildsAndVersions.count) versions")
        }

        return (app, sizesByBuildsAndVersions)
    }

    // MARK: Internal

    static var versionsRangeLimit: ClosedRange<Int> { 1...50 }
    static var buildsRangeLimit: ClosedRange<Int> { 1...200 }
}

extension AppSizeFetcher where Self: ParsableCommand {

    public func validate() throws {
        // Validate Key ID and Issuer ID
        guard !keyID.isEmpty, !issuerID.isEmpty else {
            throw ValidationError("Both keyID and issuerID must be provided.")
        }

        // Validate Private Key Path
        let privateKeyURL = URL(fileURLWithPath: privateKeyPath)
        guard FileManager.default.fileExists(atPath: privateKeyURL.path) else {
            throw ValidationError("No file exists at the provided privateKeyPath: \(privateKeyPath)")
        }

        // Validate App ID
        guard !appID.isEmpty else {
            throw ValidationError("App ID must be provided.")
        }

        // Validate limit
        if byVersion {
            guard Self.versionsRangeLimit ~= limit else {
                throw ValidationError(
                    "Provide a limit between \(Self.versionsRangeLimit.lowerBound) and \(Self.versionsRangeLimit.upperBound)"
                )
            }
        } else {
            guard Self.buildsRangeLimit ~= limit else {
                throw ValidationError(
                    "Provide a limit between \(Self.buildsRangeLimit.lowerBound) and \(Self.buildsRangeLimit.upperBound)"
                )
            }
        }
    }
}
