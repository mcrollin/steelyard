//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import Foundation
import SwiftUI

@available(macOS 10.15, *)
public struct ThemeOptions: ParsableArguments {
    public init() { }

    @Option(name: .customLong("theme"), help: "The visual color theme applied.")
    public var colorScheme: ColorScheme = .dark
}
