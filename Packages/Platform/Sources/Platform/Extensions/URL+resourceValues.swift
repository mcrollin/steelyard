//
//  Copyright © Marc Rollin.
//

import Foundation

extension URL {

    public var fileSize: Int? {
        get throws {
            let resourceValues = try resourceValues(forKeys: [.totalFileSizeKey, .isDirectoryKey])

            guard resourceValues.isDirectory == false,
                  let fileSize = resourceValues.totalFileSize
            else {
                return nil
            }

            return fileSize
        }
    }

    public var resourcesType: URLFileResourceType? {
        get throws {
            try resourceValues(forKeys: [.fileResourceTypeKey]).fileResourceType
        }
    }
}
