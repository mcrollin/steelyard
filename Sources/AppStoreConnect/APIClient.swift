//
//  Copyright © Marc Rollin.
//

import Foundation
import HTTPTypes
import HTTPTypesFoundation
import SwiftJWT

actor APIClient {
    private let keyID: String
    private let issuerID: String
    private let audience: String
    private let privateKey: Data

    private struct Claim: Claims {
        let iss: String
        var iat = Date()
        var exp = Date().addingTimeInterval(1200)
        let aud: String
        let scope: [String]
    }

    enum RequestError: Error, CustomStringConvertible {
        case http(code: Int, data: Data)

        var description: String {
            switch self {
            case let .http(code, _):
                var explanation = ""
                switch code {
                case 400..<500:
                    explanation = "The request was invalid or cannot be otherwise served."
                case 500..<600:
                    explanation = "An error occurred on the server while processing the request."
                default:
                    explanation = "An unknown HTTP error occurred."
                }
                return "Network issue: Received HTTP status code \(code). \(explanation)"
            }
        }
    }

    init(keyID: String, issuerID: String, audience: String, privateKeyPath: String) throws {
        self.keyID = keyID
        self.issuerID = issuerID
        self.audience = audience
        privateKey = try Self.privateKey(atPath: privateKeyPath)
    }

    func send(request: HTTPRequest) async throws -> Data {
        let jwt = try jwtToken(httpMethod: request.method.rawValue, path: request.path!)

        var request = request
        request.headerFields.append(.init(name: .authorization, value: "Bearer \(jwt)"))

        let (data, response) = try await URLSession.shared.data(for: request)

        switch response.status.kind {
        case .successful:
            return data
        default:
            throw RequestError.http(
                code: response.status.code,
                data: data
            )
        }
    }

    private static func privateKey(atPath filePath: String) throws -> Data {
        try Data(contentsOf: URL(fileURLWithPath: filePath))
    }

    // Helper function to create the JWT token
    private func jwtToken(httpMethod: String, path: String) throws -> String {
        let header = Header(typ: "JWT", kid: keyID)
        let claim = Claim(iss: issuerID, aud: audience, scope: ["\(httpMethod) \(path)"])
        var jwt = JWT(header: header, claims: claim)
        return try jwt.sign(using: .es256(privateKey: privateKey))
    }
}
