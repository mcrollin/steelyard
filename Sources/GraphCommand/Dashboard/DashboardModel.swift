//
//  Copyright © Marc Rollin.
//

import Foundation

public struct DashboardModel {

    // MARK: Lifecycle

    public init(
        appName: String,
        downloadSizes: [Size]?,
        installSizes: [Size]?,
        referenceDeviceIdentifier: String?,
        darkScheme: Bool
    ) {
        self.appName = appName
        self.downloadSizes = downloadSizes
        self.installSizes = installSizes
        self.referenceDeviceIdentifier = referenceDeviceIdentifier
        self.darkScheme = darkScheme
    }

    // MARK: Public

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

    public static let universalIdentifier = "Universal"

    // MARK: Internal

    let appName: String
    let downloadSizes: [Size]?
    let installSizes: [Size]?
    let referenceDeviceIdentifier: String?
    let darkScheme: Bool
}
