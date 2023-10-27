//
//  Copyright © Marc Rollin.
//

import Foundation

extension Int {

    public func formattedBytes(
        allowedUnits: ByteCountFormatter.Units? = nil,
        countStyle: ByteCountFormatter.CountStyle = .file
    )
    -> String {
        let formatter = ByteCountFormatter()..{
            if let allowedUnits {
                $0.allowedUnits = allowedUnits
            }
            $0.countStyle = countStyle
        }

        return formatter.string(fromByteCount: Int64(self))
    }
}
