//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import Foundation

public struct ExportOptions: ParsableArguments {
    public init() { }

    @Flag(name: .customLong("download-size"), inversion: .prefixedNo, help: "Include download sizes.")
    public var includeDownloadSize = true

    @Flag(name: .customLong("install-size"), inversion: .prefixedNo, help: "Include install sizes.")
    public var includeInstallSize = true

    @Option(name: .shortAndLong, help: "Specify the destination path for the generated file.")
    public var output: String?
}
