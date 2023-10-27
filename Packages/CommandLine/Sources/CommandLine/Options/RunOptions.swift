//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import Foundation

// MARK: - RunOptions

public struct RunOptions: ParsableArguments {
    public init() { }

    @Flag(
        name: .shortAndLong,
        help: "Launch an interactive UI for easier navigation in the data. (note: cancels any export configuration)"
    )
    public var interactive = false
}
