//
//  Copyright © Marc Rollin.
//

import Foundation

public struct DashboardModel {
    public struct Size {
        let version: String
        let universal: Int?
        let reference: Int?
        let thinned: ClosedRange<Int>

        public init(version: String, universal: Int? = nil, reference: Int? = nil, thinned: ClosedRange<Int>) {
            self.version = version
            self.universal = universal
            self.reference = reference
            self.thinned = thinned
        }
    }

    let appName: String
    let downloadSizes: [Size]?
    let installSizes: [Size]?
    let referenceDeviceIdentifier: String?
    public static let universalIdentifier = "Universal"

    public init(
        appName: String,
        downloadSizes: [Size]?,
        installSizes: [Size]?,
        referenceDeviceIdentifier: String?
    ) {
        self.appName = appName
        self.downloadSizes = downloadSizes
        self.installSizes = installSizes
        self.referenceDeviceIdentifier = referenceDeviceIdentifier
    }
}
