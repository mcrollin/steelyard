//
//  Copyright © Marc Rollin.
//

import ApplicationArchive
import Foundation
import SwiftUI
import TreeMap

extension ApplicationArchive.Node: TreeMapDisplayable {

    // MARK: Public

    public var id: URL { url }

    public var description: String {
        [contentType?.displayName.map { "[\($0)]" }, name, "(\(sizeInBytes.formattedBytes()))"]
            .compactMap { $0 }
            .joined(separator: " ")
    }

    public var color: Color? {
        guard !isDuplicate else {
            return .red
        }

        return switch category {
        case .appExtension: .brown
        case .assetCatalog: .green
        case .binary: .blue
        case .bundle: .indigo
        case .content: .mint
        case .data: .gray
        case .font: .cyan
        case .framework: .brown
        case .localization: .orange
        case .model: .purple
        case .folder: nil
        }
    }

    public var shouldShowDetails: Bool {
        guard !children.isEmpty, !isDuplicate else {
            return false
        }

        return switch category {
        case .localization, .model: false
        default: true
        }
    }

    public var size: CGFloat {
        CGFloat(sizeInBytes)
    }

    public var segments: [ApplicationArchive.Node] {
        children
    }

    // MARK: Fileprivate

    fileprivate enum Category {
        case appExtension
        case assetCatalog
        case binary
        case bundle
        case content
        case data
        case folder
        case font
        case framework
        case localization
        case model

        // MARK: Lifecycle

        init(node: ApplicationArchive.Node) {
            self = switch node.contentType {
            case .asset?:
                .assetCatalog
            case .binary?:
                .binary
            case .binarySection?:
                .binary
            case .package(let packageExtension)?:
                switch packageExtension {
                case .appex: .appExtension
                case .bundle: .bundle
                case .car: .assetCatalog
                case .framework: .framework
                case .lproj: .localization
                case .mlmodelc, .momd: .model
                }
            case .universal(let utType)?:
                if utType.isSubtype(of: .content) { .content }
                else if utType.isSubtype(of: .data) { .data }
                else if utType.isSubtype(of: .font) { .font }
                else { .data }
            case nil:
                node.resourceType == .directory ? .folder : .data
            }
        }
    }

    fileprivate var category: Category {
        .init(node: self)
    }

}
