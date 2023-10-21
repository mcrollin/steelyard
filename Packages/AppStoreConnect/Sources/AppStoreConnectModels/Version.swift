//
//  Copyright © Marc Rollin.
//

import Foundation

public struct Version: Decodable {
    public let id: String
    public let version: String

    private enum CodingKeys: String, CodingKey {
        case id
        case attributes
    }

    private enum AttributesCodingKeys: String, CodingKey {
        case versionString
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)

        let attributesContainer = try container.nestedContainer(keyedBy: AttributesCodingKeys.self, forKey: .attributes)
        version = try attributesContainer.decode(String.self, forKey: .versionString)
    }
}
