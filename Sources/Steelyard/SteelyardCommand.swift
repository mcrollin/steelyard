//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import Foundation
import Graph

// MARK: - Steelyard

@main
struct SteelyardCommand: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "steelyard",
        abstract: "Analytics and visualization app size utility for Apple platforms developers.",
        subcommands: [GraphCommand.self]
    )
}
