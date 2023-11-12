//
//  Copyright © Marc Rollin.
//

import AppStoreConnect
import Foundation
import SwiftUI

extension DashboardModel {

    init(
        app: Application,
        buildsSizes: [BuildSizes],
        includeDownloadSize: Bool,
        includeInstallSize: Bool,
        referenceDeviceIdentifier: String?
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
            referenceDeviceIdentifier: referenceDeviceIdentifier
        )
    }
}

extension DashboardModel.Size {

    // MARK: Lifecycle

    fileprivate init(buildSizes: BuildSizes, category: Category, referenceDeviceIdentifier: String? = nil) {
        let keyPath: KeyPath<BuildBundleFileSize, Int> = switch category {
        case .download: \.downloadBytes
        case .install: \.installBytes
        }

        var sizeByDevice = buildSizes.fileSizes.reduce(into: [String: Int]()) { result, size in
            result[size.deviceModel] = size[keyPath: keyPath]
        }
        let universal = sizeByDevice.removeValue(forKey: DashboardModel.universalIdentifier)

        let prefixes = DashboardModel.Size.Categories.allCases.map(\.name)
        var thinned: [String: ClosedRange<Int>] = prefixes.reduce(into: [:]) { acc, prefix in
            let filteredSizes = sizeByDevice.filter { $0.key.hasPrefix(prefix) }.map(\.value)
            if let minSize = filteredSizes.min(), let maxSize = filteredSizes.max() {
                acc[prefix] = minSize...maxSize
            }
        }

        let otherSizes = sizeByDevice.filter { key, _ in !prefixes.contains { key.hasPrefix($0) } }.map(\.value)
        if let minOther = otherSizes.min(), let maxOther = otherSizes.max() {
            thinned[DashboardModel.Size.Categories.others.name] = minOther...maxOther
        }

        self.init(
            version: buildSizes.version?.version ?? buildSizes.build.version,
            universal: universal,
            reference: referenceDeviceIdentifier != nil ? sizeByDevice[referenceDeviceIdentifier!] : nil,
            thinned: thinned
        )
    }

    // MARK: Fileprivate

    fileprivate enum Category {
        case download, install
    }
}
