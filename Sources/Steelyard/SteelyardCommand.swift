//
//  Copyright © Marc Rollin.
//

import Archive
import ArgumentParser
import Foundation
import History

@main
struct SteelyardCommand: AsyncParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "steelyard",
        abstract: "Analyze and optimize your Apple app's build sizes.",
        subcommands: [HistoryCommand.self, ArchiveCommand.self]
    )
}
