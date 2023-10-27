//
//  Copyright © Marc Rollin.
//

import Foundation
import Platform
import Zip

// MARK: - ApplicationArchive

public final class ApplicationArchive {

    // MARK: Lifecycle

    public init(at url: URL, isCompressed: Bool = true) throws {
        let archiveURL: URL

        if isCompressed {
            let uncompressed = FileManager.default
                .temporaryDirectory
                .appendingPathComponent(UUID().uuidString)

            Zip.addCustomFileExtension(url.pathExtension)
            try Zip.unzipFile(url, destination: uncompressed, overwrite: true, password: nil)
            archiveURL = uncompressed
        } else {
            archiveURL = url
        }

        root = try Self.buildNode(from: archiveURL)
        root.computeSizes()
        buildIndex(from: root)
        markDuplicates()
    }

    // MARK: Public

    public final class Node {

        // MARK: Lifecycle

        public init(
            from url: URL,
            name: String? = nil,
            resourceType: URLFileResourceType? = nil,
            contentType: ContentType? = nil
        ) {
            self.url = url
            self.name = name ?? url.lastPathComponent
            self.resourceType = resourceType ?? (try? url.resourcesType)
            self.contentType = contentType ?? url.contentType
            if let fileSize = try? url.fileSize {
                sizeInBytes = fileSize
            }
        }

        // MARK: Public

        public typealias Checksum = String

        public let url: URL
        public let name: String
        public let resourceType: URLFileResourceType?
        public let contentType: ContentType?
        public var sizeInBytes = -1
        public var children: [Node] = []
        public var isDuplicate = false
        public var checksum: Checksum?
    }

    public struct Duplicate {
        public let nodes: [Node]

        public var sizeInBytes: Int {
            nodes.first?.sizeInBytes ?? -1
        }

        public var duplicateSizeInBytes: Int {
            sizeInBytes * (nodes.count - 1)
        }
    }

    public let root: Node

    public var allDuplicates: [Duplicate] {
        index.allDuplicates
    }

    public var topLevelDuplicates: [Duplicate] {
        var duplicates = [Node.Checksum: Duplicate]()
        topLevelDuplicates(from: root, duplicates: &duplicates)
        return Array(duplicates.values)
    }

    public var description: String {
        var description = ""
        describe(node: root, description: &description)
        return description
    }

    // MARK: Internal

    // MARK: - TreeError

    enum TreeError: Error {
        case fileDoesNotExist
    }

    // MARK: Private

    private final class Index {

        // MARK: Internal

        var allDuplicates: [Duplicate] {
            byChecksum.values
                .filter { $0.count > 1 }
                .map(Duplicate.init)
        }

        func duplicate(from node: Node) -> Duplicate? {
            guard let checksum = node.checksum,
                  let nodes = byChecksum[checksum],
                  nodes.count > 1
            else {
                return nil
            }

            return .init(nodes: nodes)
        }

        func insert(node: Node) {
            guard let checksum = node.checksum else { return }
            byChecksum[checksum] = (byChecksum[checksum] ?? []) + CollectionOfOne(node)
        }

        // MARK: Private

        private var byChecksum = [Node.Checksum: [Node]]()
    }

    private static let fileManager = FileManager.default

    private var index = Index()

    private static func buildNode(from url: URL) throws -> Node {
        guard Self.fileManager.fileExists(atPath: url.path) else {
            throw TreeError.fileDoesNotExist
        }

        return try .init(from: url)..{
            try configure(node: $0)
        }
    }

    private static func configure(node: Node) throws {
        switch node.resourceType {
        case .directory?: try configureDirectory(node)
        case .regular?: try configureFile(node)
        default: break
        }
    }

    private static func configureDirectory(_ node: Node) throws {
        node.children = try Self.fileManager.contentsOfDirectory(at: node.url, includingPropertiesForKeys: [])
            .compactMap(buildNode(from:))

        let checksum: String = node.children
            .compactMap(\.checksum)
            .sorted()
            .joined()

        if checksum.isEmpty == false {
            node.checksum = checksum.sha256
        }
    }

    private static func configureFile(_ node: Node) throws {
        switch node.contentType {
        case .package(.car):
            if let content = try? node.assetCatalogContent() {
                node.children = content
            }
        case .binary:
            if let content = try? node.binaryContent() {
                node.children = content
            }
        default:
            break
        }

        node.checksum = try Data(contentsOf: node.url).sha256
    }

    private func buildIndex(from node: Node) {
        index.insert(node: node)
        node.children.forEach(buildIndex(from:))
    }

    private func markDuplicates() {
        index.allDuplicates
            .flatMap(\.nodes)
            .forEach { $0.isDuplicate = true }
    }

    private func topLevelDuplicates(from node: Node, duplicates: inout [Node.Checksum: Duplicate]) {
        if let checksum = node.checksum, let duplicate = index.duplicate(from: node) {
            if duplicates[checksum] == nil {
                duplicates[checksum] = duplicate
            }
        } else {
            node.children.forEach {
                topLevelDuplicates(from: $0, duplicates: &duplicates)
            }
        }
    }

    private func describe(node: ApplicationArchive.Node, level: Int = 0, description: inout String) {
        let indentation = String(repeating: "   ", count: level)
        description.append("\(indentation)\(node)\n")

        for child in node.children {
            describe(node: child, level: level + 1, description: &description)
        }
    }
}

extension ApplicationArchive.Node {

    // MARK: Fileprivate

    @discardableResult
    fileprivate func computeSizes() -> Int {
        if children.isEmpty {
            return sizeInBytes
        }

        sizeInBytes = children
            .map { $0.computeSizes() }
            .reduce(0, +)

        return sizeInBytes
    }

    fileprivate func binaryContent() throws -> [ApplicationArchive.Node] {
        let process = Process()
        let outputPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/bin/size")
        process.arguments = [url.relativePath]
        process.standardOutput = outputPipe
        try process.run()
        process.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        guard let outputString = String(data: outputData, encoding: .utf8) else {
            throw ContentError.dataToStringConversionFailed
        }

        let lines = outputString.split(separator: "\n")
        guard lines.count >= 2 else {
            throw ContentError.unexpectedOutputFormat
        }

        let keys = lines[0].split(separator: "\t").map { $0.trimmingCharacters(in: .whitespaces) }
        let values = lines[1].split(separator: "\t").map { $0.trimmingCharacters(in: .whitespaces) }
        var sizeInfo: [String: Int] = Dictionary(
            uniqueKeysWithValues: zip(keys, values)
                .compactMap { key, value -> (String, Int)? in
                    guard key != "hex", let intValue = Int(value) else {
                        return nil
                    }
                    return (key, intValue)
                }
        )

        guard let totalSize = sizeInfo.removeValue(forKey: "dec"), totalSize > 0 else {
            throw ContentError.missingTotalSize
        }

        return sizeInfo.reduce(into: [ApplicationArchive.Node]()) { result, keyValue in
            let (key, value) = keyValue
            result.append(.init(
                from: url.appendingPathComponent(UUID().uuidString),
                name: key,
                contentType: .binarySection
            )..{
                $0.checksum = $0.url.relativePath.sha256
                $0.sizeInBytes = Int(Float(value) / Float(totalSize) * Float(sizeInBytes))
            })
        }
    }

    fileprivate func assetCatalogContent() throws -> [ApplicationArchive.Node] {
        let process = Process()
        let outputPipe = Pipe()
        let group = DispatchGroup()
        var processError: Error?
        var outputData: Data?

        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["assetutil", "--info", url.relativePath]
        process.standardOutput = outputPipe

        group.enter()
        DispatchQueue.global().async {
            do {
                try process.run()
                process.waitUntilExit()
            } catch {
                processError = error
            }
            group.leave()
        }

        let outputHandle = outputPipe.fileHandleForReading
        group.enter()
        DispatchQueue.global().async {
            outputData = outputHandle.readDataToEndOfFile()
            group.leave()
        }

        group.wait()

        if let error = processError {
            throw error
        }

        guard let outputData else {
            throw ContentError.unexpectedOutputFormat
        }

        return try JSONDecoder().decode([AssetInfo].self, from: outputData)
            .compactMap { asset in
                guard let fileName = asset.renditionName ?? asset.name,
                      let size = asset.sizeOnDisk
                else { return nil }
                return .init(
                    from: url.appendingPathComponent(UUID().uuidString),
                    name: fileName,
                    contentType: .asset
                )..{
                    $0.checksum = asset.sha1Digest
                    $0.sizeInBytes = size
                }
            }
    }

    // MARK: Private

    private struct AssetInfo: Codable {
        let assetType: String?
        let name: String?
        let renditionName: String?
        let sizeOnDisk: Int?
        let sha1Digest: String?
        let preservedVectorRepresentation: Bool?

        enum CodingKeys: String, CodingKey {
            case assetType = "AssetType"
            case name = "Name"
            case renditionName = "RenditionName"
            case sizeOnDisk = "SizeOnDisk"
            case sha1Digest = "SHA1Digest"
            case preservedVectorRepresentation = "Preserved Vector Representation"
        }
    }

    private enum ContentError: Error {
        case dataToStringConversionFailed
        case unexpectedOutputFormat
        case missingTotalSize
    }
}
