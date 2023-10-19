//
//  Copyright © Marc Rollin.
//

import AppStoreConnect
import Foundation

struct AppSizeData: Codable {

    // MARK: Lifecycle

    init(
        app: Application,
        sizesByBuildAndVersions: [SizesByBuildAndVersion],
        includeDownloadSize: Bool,
        includeInstallSize: Bool
    ) {
        let sizes = sizesByBuildAndVersions.reduce(into: (
            download: [String: Sizes.DeviceSizes](),
            install: [String: Sizes.DeviceSizes]()
        )) { result, sizesByBuildAndVersion in
            let key = sizesByBuildAndVersion.version?.version ?? sizesByBuildAndVersion.build.version

            result.download[key] = includeDownloadSize
                ? sizesByBuildAndVersion.fileSizes.reduce(into: Sizes.DeviceSizes()) { dict, fileSize in
                    dict[fileSize.deviceModel] = fileSize.downloadBytes
                }
                : nil

            result.install[key] = includeInstallSize
                ? sizesByBuildAndVersion.fileSizes.reduce(into: Sizes.DeviceSizes()) { dict, fileSize in
                    dict[fileSize.deviceModel] = fileSize.installBytes
                }
                : nil
        }

        appName = app.name
        self.sizes = Sizes(download: sizes.download, install: sizes.install)
    }

    // MARK: Internal

    struct Sizes: Codable {
        typealias DeviceSizes = [String: Int]

        let download: [String: DeviceSizes]?
        let install: [String: DeviceSizes]?
    }

    let appName: String
    let sizes: Sizes

    func write(to filePath: String? = nil) async throws -> URL {
        let data = try JSONEncoder().encode(self)

        let url: URL
        if let filePath {
            url = URL(fileURLWithPath: filePath)
        } else {
            url = FileManager.default
                .temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("json")
        }
        try data.write(to: url)
        return url
    }

}
