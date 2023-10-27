//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import Foundation

struct FetchOptions: ParsableArguments {

    // MARK: Lifecycle

    init() { }

    // MARK: Internal

    static let versionsRangeLimit: ClosedRange<Int> = 1...50
    static let buildsRangeLimit: ClosedRange<Int> = 1...200

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
    var limit = 30

    @Flag(help: "Fetch sizes categorized by version, not build. Slower to retrieve.")
    var byVersion = false

}
