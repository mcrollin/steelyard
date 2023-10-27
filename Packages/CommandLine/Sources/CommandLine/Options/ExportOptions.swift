//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import Foundation

// MARK: - ExportOptions

public struct ExportOptions<Format: ExportFormat>: ParsableArguments {
    public init() { }

    @Option(name: .shortAndLong, help: "Specify the destination path.", transform: URL.init(fileURLWithPath:))
    public var output: URL?

    @Option(name: .shortAndLong, help: "The output format")
    public var format = Format.defaultValue
}

// MARK: - ExportFormat

public protocol ExportFormat: ExpressibleByArgument {
    static var defaultValue: Self { get }
}

// MARK: - GraphicExportFormat

public enum GraphicExportFormat: String, ExportFormat {
    case png, pdf

    public static var defaultValue: Self = .pdf
}

// MARK: - DataExportFormat

public enum DataExportFormat: String, ExportFormat {
    case json

    public static var defaultValue: Self = .json
}
