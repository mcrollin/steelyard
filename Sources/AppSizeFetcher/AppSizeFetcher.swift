//
//  File.swift
//  
//
//  Created by Marc Rollin on 19/10/2023.
//

import AppStoreConnect
import Console
import Foundation

public struct AppSizeFetcher {
    private let appStoreConnect: AppStoreConnect

    public init(keyID: String, issuerID: String, privateKeyPath: String) throws {
        appStoreConnect = try AppStoreConnect(
            keyID: keyID,
            issuerID: issuerID,
            privateKeyPath: privateKeyPath
        )
    }

    public func fetch(
        appID: String,
        byVersion: Bool,
        limit: Int,
        verbose: Bool
    ) async throws -> (Application, [SizesByBuildAndVersion]) {
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
}
