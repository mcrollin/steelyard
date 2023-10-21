//
//  Copyright © Marc Rollin.
//

import AppStoreConnectModels
import Foundation

extension DashboardModel {

    init(
        app: Application,
        buildsSizes: [BuildSizes],
        includeDownloadSize: Bool,
        includeInstallSize: Bool,
        referenceDeviceIdentifier: String?,
        darkScheme: Bool
    ) {
        self.init(
            appName: app.name,
            downloadSizes: includeDownloadSize
                ? buildsSizes.map { buildSizes in
                    .init(
                        buildSizes: buildSizes,
                        category: .download,
                        referenceDeviceIdentifier: referenceDeviceIdentifier
                    )
                }
                : nil,
            installSizes: includeInstallSize
                ? buildsSizes.map { buildSizes in
                    .init(
                        buildSizes: buildSizes,
                        category: .install,
                        referenceDeviceIdentifier: referenceDeviceIdentifier
                    )
                }
                : nil,
            referenceDeviceIdentifier: referenceDeviceIdentifier,
            darkScheme: darkScheme
        )
    }
}

extension DashboardModel.Size {

    // MARK: Lifecycle

    fileprivate init(buildSizes: BuildSizes, category: Category, referenceDeviceIdentifier: String? = nil) {
        let keyPath: KeyPath<BuildBundleFileSize, Int>

        switch category {
        case .download:
            keyPath = \.downloadBytes
        case .install:
            keyPath = \.installBytes
        }

        var sizeByDevice = buildSizes.fileSizes.reduce(into: [String: Int]()) { result, size in
            result[size.deviceModel] = size[keyPath: keyPath]
        }
        let universal = sizeByDevice.removeValue(forKey: DashboardModel.universalIdentifier)
        let thinnedSizes = sizeByDevice.values

        self.init(
            version: buildSizes.version?.version ?? buildSizes.build.version,
            universal: universal,
            reference: referenceDeviceIdentifier != nil ? sizeByDevice[referenceDeviceIdentifier!] : nil,
            thinned: (thinnedSizes.min() ?? 0)...(thinnedSizes.max() ?? 0)
        )
    }

    // MARK: Fileprivate

    fileprivate enum Category {
        case download, install
    }
}
