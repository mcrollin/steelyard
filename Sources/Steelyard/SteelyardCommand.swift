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
        abstract: "Generate insightful App Size Graphs & JSON Metrics using App Store Connect API.",
        subcommands: [GraphCommand.self, DataCommand.self]
    )
}
