//
//  Copyright © Marc Rollin.
//

import AppStoreConnect
import AppStoreConnectModels
import ArgumentParser
import Console
import Foundation

// MARK: - AppSizeFetcher

public protocol AppSizeFetcher {
    var appStoreConnectArguments: AppStoreConnectArguments { get }
    var fetchOptions: FetchOptions { get }
    var exportOptions: ExportOptions { get }
    var runOptions: RunOptions { get }

    func fetchAppSize() async throws -> (Application, [BuildSizes])
}

extension AppSizeFetcher {

    public func fetchAppSize() async throws -> (Application, [BuildSizes]) {
        let appStoreConnect: AppStoreConnect = try AppStoreConnect(
            keyID: appStoreConnectArguments.keyID,
            issuerID: appStoreConnectArguments.issuerID,
            privateKeyPath: appStoreConnectArguments.privateKeyPath
        )

        let app = try await appStoreConnect.app(appID: appStoreConnectArguments.appID)
        Console.info("Successfully identified app with ID \(app.id): \"\(app.name)\"")

        let buildsSizes: [BuildSizes]

        if fetchOptions.byVersion {
            Console.debug("Fetching \(fetchOptions.limit) most recent versions (may take some time)…")
            let versions = try await appStoreConnect.versions(app: app, limit: fetchOptions.limit)
            Console.info("Retrieved \(versions.count) most recent versions (maximum limit set to \(fetchOptions.limit))")

            Console.debug("")
            buildsSizes = try await appStoreConnect.sizes(versions: versions) { progress in
                Console.debug(
                    "Fetching individual version sizes… \(Console.progress(progress, columns: 40))",
                    prefix: "\u{1B}[1A\u{1B}[K"
                )
            }
            Console.info("Fetched file sizes for \(buildsSizes.count) builds")
        } else {
            Console.debug("Fetching \(fetchOptions.limit) most recent builds…")
            let builds = try await appStoreConnect.builds(app: app, limit: fetchOptions.limit)
            Console.info("Retrieved \(builds.count) most recent builds (maximum limit set to \(fetchOptions.limit))")

            Console.debug("")
            buildsSizes = try await appStoreConnect.sizes(builds: builds) { progress in
                Console.debug(
                    "Fetching individual build sizes… \(Console.progress(progress, columns: 40))",
                    prefix: "\u{1B}[1A\u{1B}[K"
                )
            }
            Console.info("Fetched file sizes for \(buildsSizes.count) versions")
        }

        return (app, buildsSizes)
    }
}

extension AppSizeFetcher where Self: ParsableCommand {

    public func validate() throws {
        // Validate Key ID and Issuer ID
        guard !appStoreConnectArguments.keyID.isEmpty, !appStoreConnectArguments.issuerID.isEmpty else {
            throw ValidationError("Both keyID and issuerID must be provided.")
        }

        // Validate Private Key Path
        let privateKeyURL = URL(fileURLWithPath: appStoreConnectArguments.privateKeyPath)
        guard FileManager.default.fileExists(atPath: privateKeyURL.path) else {
            throw ValidationError("No file exists at the provided privateKeyPath: \(appStoreConnectArguments.privateKeyPath)")
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
