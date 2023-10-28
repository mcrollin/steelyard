//
//  Copyright © Marc Rollin.
//

import AppStoreConnect
import Foundation

struct AppSizeData: Codable {

    // MARK: Lifecycle

    init(
        app: Application,
        buildsSizes: [BuildSizes],
        includeDownloadSize: Bool,
        includeInstallSize: Bool
    ) {
        id = app.id
        name = app.name
        bundle_id = app.bundleId
        builds = buildsSizes.reduce(into: [String: BuildData]()) { result, buildSizes in
            result[buildSizes.version?.version ?? buildSizes.build.version] = .init(
                id: buildSizes.build.id,
                uploaded_date: buildSizes.build.uploadedDate,
                version: buildSizes.build.version,
                marketing_version: buildSizes.version?.version,
                sizes: buildSizes.fileSizes.reduce(into: [BuildData.DeviceData]()) { sizes, fileSize in
                    sizes.append(.init(
                        id: fileSize.id,
                        device_model: fileSize.deviceModel,
                        os_version: fileSize.osVersion,
                        download_bytes: includeDownloadSize ? fileSize.downloadBytes : nil,
                        install_bytes: includeInstallSize ? fileSize.installBytes : nil
                    ))
                }
            )
        }
    }

    // MARK: Internal

    struct BuildData: Codable {
        struct DeviceData: Codable {
            let id: String
            let device_model: String
            let os_version: String
            let download_bytes: Int?
            let install_bytes: Int?
        }

        let id: String
        let uploaded_date: Date
        let version: String
        let marketing_version: String?
        let sizes: [DeviceData]
    }

    let id: String
    let name: String
    let bundle_id: String
    let builds: [String: BuildData]

    func write(to url: URL? = nil) async throws -> URL {
        let data = try JSONEncoder().encode(self)
        let url = url ?? FileManager.default
            .temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")

        try data.write(to: url)
        return url
    }
}
