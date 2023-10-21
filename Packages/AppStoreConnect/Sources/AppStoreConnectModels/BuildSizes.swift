//
//  Copyright © Marc Rollin.
//

import Foundation

public struct BuildSizes {
    public let version: Version?
    public let build: Build
    public let fileSizes: [BuildBundleFileSize]

    public init(version: Version? = nil, build: Build, fileSizes: [BuildBundleFileSize]) {
        self.version = version
        self.build = build
        self.fileSizes = fileSizes
    }
}
