//
//  Copyright © Marc Rollin.
//

import Foundation

public struct BuildBundle: Decodable {

    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)

        let attributesContainer = try container.nestedContainer(keyedBy: AttributesCodingKeys.self, forKey: .attributes)
        bundleType = try attributesContainer.decode(String.self, forKey: .bundleType)
    }

    // MARK: Public

    public let id: String
    public let bundleType: String

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
        case id
        case attributes
    }

    private enum AttributesCodingKeys: String, CodingKey {
        case bundleType
    }
}
