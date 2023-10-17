//
//  Copyright © Marc Rollin.
//

import Foundation

public struct SizesByBuildAndVersion {
    public let version: Version?
    public let build: Build
    public let fileSizes: [BuildBundleFileSize]
}
