//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import Foundation

public struct FetchOptions: ParsableArguments {

    // MARK: Lifecycle

    public init() { }

    // MARK: Public

    @Option(
        name: .shortAndLong,
        help: .init(
            "Specify the number of items to analyze.",
            discussion:
            """
            - For builds, the range is \(Self.buildsRangeLimit.lowerBound) to \(Self.buildsRangeLimit.upperBound).
            - For versions, the range is \(Self.versionsRangeLimit.lowerBound) to \(Self.versionsRangeLimit.upperBound).
            """
        )
    )
    public var limit = 30

    @Flag(help: "Fetch sizes categorized by version, not build. Slower to retrieve.")
    public var byVersion = false

    // MARK: Internal

    static let versionsRangeLimit: ClosedRange<Int> = 1...50
    static let buildsRangeLimit: ClosedRange<Int> = 1...200
}
