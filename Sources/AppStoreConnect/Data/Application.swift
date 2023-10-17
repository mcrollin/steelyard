//
//  Copyright © Marc Rollin.
//

import Foundation

public struct Application: Decodable {
    public let id: String
    public let name: String
    public let bundleId: String

    private enum CodingKeys: String, CodingKey {
        case id
        case attributes
        case relationships
    }

    private enum AttributesCodingKeys: String, CodingKey {
        case name
        case bundleId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)

        let attributesContainer = try container.nestedContainer(keyedBy: AttributesCodingKeys.self, forKey: .attributes)
        name = try attributesContainer.decode(String.self, forKey: .name)
        bundleId = try attributesContainer.decode(String.self, forKey: .bundleId)
    }
}
