//
//  Copyright © Marc Rollin.
//

import CommandLine
import Foundation
import SwiftUI

struct DashboardModel {

    // MARK: Lifecycle

    init(
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

    // MARK: Internal

    struct Size {

        // MARK: Lifecycle

        init(version: String, universal: Int? = nil, reference: Int? = nil, thinned: [String: ClosedRange<Int>]) {
            self.version = version
            self.universal = universal
            self.reference = reference
            self.thinned = thinned
        }

        // MARK: Internal

        enum Categories: String, CaseIterable, Identifiable {
            case watch = "Watch"
            case iPad, iPhone
            case others = "Others"

            public var id: String {
                rawValue
            }

            public var name: String {
                rawValue
            }
        }

        let version: String
        let universal: Int?
        let reference: Int?
        let thinned: [String: ClosedRange<Int>]

    }

    static let universalIdentifier = "Universal"

    let appName: String
    let downloadSizes: [Size]?
    let installSizes: [Size]?
    let referenceDeviceIdentifier: String?
}
