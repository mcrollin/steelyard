//
//  Copyright © Marc Rollin.
//

import AppStoreConnect
import AppStoreConnectModels
import ArgumentParser
import CommandLine
import Foundation

// MARK: - BuildSizeHistoryFetcher

protocol BuildSizeHistoryFetcher {
    associatedtype Format: ExportFormat

    var appStoreConnectArguments: AppStoreConnectArguments { get }
    var fetchOptions: FetchOptions { get }
    var sizeOptions: SizeOptions { get }
    var exportOptions: ExportOptions<Format> { get }
    var consoleOptions: ConsoleOptions { get }

    func fetchHistory() async throws -> BuildSizeHistory
}

extension BuildSizeHistoryFetcher {

    // MARK: Internal

    func fetchHistory() async throws -> BuildSizeHistory {
        let appStoreConnect: AppStoreConnect = try AppStoreConnect(
            keyID: appStoreConnectArguments.keyID,
            issuerID: appStoreConnectArguments.issuerID,
            privateKey: appStoreConnectArguments.privateKey
        )

        let app = try await appStoreConnect.app(appID: appStoreConnectArguments.appID)
        Console.notice("Successfully identified app with ID \(app.id): \"\(app.name)\"")

        let sizes: [BuildSizes]

        if fetchOptions.byVersion {
            Console.notice("Fetching \(fetchOptions.limit) most recent versions (may take some time)…")
            let versions = try await appStoreConnect.versions(app: app, limit: fetchOptions.limit)
            Console.notice("Retrieved \(versions.count) most recent versions (maximum limit set to \(fetchOptions.limit))")

            Console.notice("Fetching individual version sizes (may take a bit of time)")
            printProgress(progress: 0, clearPreviousLine: false)
            sizes = try await appStoreConnect.sizes(versions: versions) { progress in
                printProgress(progress: progress)
            }
            Console.notice("Fetched file sizes for \(sizes.count) builds")
        } else {
            Console.notice("Fetching \(fetchOptions.limit) most recent builds…")
            let builds = try await appStoreConnect.builds(app: app, limit: fetchOptions.limit)
            Console.notice("Retrieved \(builds.count) most recent builds (maximum limit set to \(fetchOptions.limit))")

            Console.notice("Fetching individual build sizes")
            printProgress(progress: 0, clearPreviousLine: false)
            sizes = try await appStoreConnect.sizes(builds: builds) { progress in
                printProgress(progress: progress)
            }
            Console.notice("Fetched file sizes for \(sizes.count) versions")
        }

        return .init(app: app, sizes: sizes)
    }

    // MARK: Private

    private func printProgress(progress: Float, clearPreviousLine: Bool = true) {
        Console.info(
            "\(Console.progress(progress, columns: 40))",
            prefix: "\u{1B}[1A\u{1B}[K"
        )
    }
}

extension BuildSizeHistoryFetcher where Self: ParsableCommand {

    func validate() throws {
        // Validate Key ID and Issuer ID
        guard !appStoreConnectArguments.keyID.isEmpty, !appStoreConnectArguments.issuerID.isEmpty else {
            throw ValidationError("Both keyID and issuerID must be provided.")
        }

        // Validate Private Key Path
        guard FileManager.default.fileExists(atPath: appStoreConnectArguments.privateKey.path) else {
            throw ValidationError("No file exists at the provided path: \(appStoreConnectArguments.privateKey)")
        }

        // Validate App ID
        guard !appStoreConnectArguments.appID.isEmpty else {
            throw ValidationError("App ID must be provided.")
        }

        // Validate limit
        if fetchOptions.byVersion {
            guard FetchOptions.versionsRangeLimit ~= fetchOptions.limit else {
                throw ValidationError(
                    "Provide a limit between \(FetchOptions.versionsRangeLimit.lowerBound) and \(FetchOptions.versionsRangeLimit.upperBound)"
                )
            }
        } else {
            guard FetchOptions.buildsRangeLimit ~= fetchOptions.limit else {
                throw ValidationError(
                    "Provide a limit between \(FetchOptions.buildsRangeLimit.lowerBound) and \(FetchOptions.buildsRangeLimit.upperBound)"
                )
            }
        }
    }
}
