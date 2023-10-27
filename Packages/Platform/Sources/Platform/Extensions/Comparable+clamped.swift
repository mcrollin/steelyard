//
//  Copyright © Marc Rollin.
//

import Foundation

extension Comparable {

    public func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
