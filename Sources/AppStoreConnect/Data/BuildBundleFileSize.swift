//
//  Copyright © Marc Rollin.
//

import Foundation

public struct BuildBundleFileSize: Decodable, Identifiable {
    public let id: String
    public let deviceModel: String
    public let osVersion: String
    public let downloadBytes: Int
    public let installBytes: Int

    private enum CodingKeys: String, CodingKey {
        case id
        case attributes
    }

    private enum AttributesCodingKeys: String, CodingKey {
        case deviceModel
        case osVersion
        case downloadBytes
        case installBytes
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let attributesContainer = try container.nestedContainer(keyedBy: AttributesCodingKeys.self, forKey: .attributes)

        id = try container.decode(String.self, forKey: .id)
        deviceModel = try attributesContainer.decode(String.self, forKey: .deviceModel)
        osVersion = try attributesContainer.decode(String.self, forKey: .osVersion)
        downloadBytes = try attributesContainer.decode(Int.self, forKey: .downloadBytes)
        installBytes = try attributesContainer.decode(Int.self, forKey: .installBytes)
    }
}
