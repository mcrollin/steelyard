//
//  Copyright © Marc Rollin.
//

import Foundation

// MARK: - ErrorResponse

struct ErrorResponse: Error, Codable, CustomStringConvertible {
    let errors: [ErrorDetail]

    var description: String {
        errors.map(\.detail).joined(separator: "\n")
    }
}

// MARK: - ErrorDetail

struct ErrorDetail: Codable {
    let status: String
    let code: String
    let title: String
    let detail: String
}
