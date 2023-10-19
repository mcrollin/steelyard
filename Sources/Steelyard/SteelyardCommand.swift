//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import Commands
import Foundation

@main
struct SteelyardCommand: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "steelyard",
        abstract: "Analytics and visualization app size utility for Apple platforms developers.",
        subcommands: [GraphCommand.self, DataCommand.self]
    )
}
