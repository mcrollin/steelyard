//
//  Copyright © Marc Rollin.
//

import CryptoKit
import Foundation

extension Data {

    public var sha256: String {
        SHA256.hash(data: self)
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
}

extension String {

    public var sha256: String? {
        data(using: .utf8)?.sha256
    }
}
