//
//  Copyright © Marc Rollin.
//

import Foundation
import UniformTypeIdentifiers

// MARK: - ContentType

public enum ContentType: CustomStringConvertible {
    case asset
    case binary(BinaryFileType)
    case binarySection
    case package(PackageExtension)
    case universal(UTType)

    // MARK: Public

    public enum PackageExtension: String, CustomStringConvertible {
        case appex
        case bundle
        case car
        case framework
        case lproj
        case mlmodelc
        case momd

        // MARK: Public

        public var description: String {
            switch self {
            case .appex:
                "App Extension"
            case .bundle:
                "Bundle"
            case .car:
                "Asset Catalog"
            case .framework:
                "Framework"
            case .mlmodelc:
                "Core ML Model"
            case .momd:
                "Core Data Model"
            case .lproj:
                "Localization Files"
            }
        }
    }

    public var description: String {
        switch self {
        case .asset:
            "Asset"
        case .binary(let binaryExtension):
            binaryExtension.description
        case .binarySection:
            "Binary Section"
        case .package(let packageExtension):
            packageExtension.description
        case .universal(let type):
            type.localizedDescription ?? type.description
        }
    }

    public var displayName: String? {
        switch self {
        case .asset, .binarySection:
            nil
        default:
            description
        }
    }
}

extension URL {

    public var contentType: ContentType? {
        if let type = binaryFileType {
            .binary(type)
        } else if let packageExtension = ContentType.PackageExtension(rawValue: pathExtension) {
            .package(packageExtension)
        } else if let type = UTType(filenameExtension: pathExtension) {
            .universal(type)
        } else {
            nil
        }
    }
}
