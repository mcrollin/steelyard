//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import Foundation

// MARK: - ConsoleOptions

public struct ConsoleOptions: ParsableArguments {
    public init() { }

    @Flag(name: .shortAndLong, help: "Display all information messages.")
    public var verbose = false

    @Flag(name: .shortAndLong, help: "Silence the output (overrides verbose mode).")
    public var silence = false
}
