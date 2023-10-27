//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import Foundation
import SwiftUI

@available(macOS 10.15, *)
extension ColorScheme: ExpressibleByArgument {

    // MARK: Lifecycle

    public init?(argument: String) {
        switch Argument(rawValue: argument) {
        case .dark?:
            self = .dark
        case .light?:
            self = .light
        default:
            return nil
        }
    }

    // MARK: Public

    public enum Argument: String {
        case dark, light
    }

}
