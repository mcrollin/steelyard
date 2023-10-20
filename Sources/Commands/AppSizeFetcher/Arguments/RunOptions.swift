//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import Foundation

public struct RunOptions: ParsableArguments {
    public init() { }

    @Flag(name: .shortAndLong, help: "Display all information messages.")
    public var verbose = false
}
