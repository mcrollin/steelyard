//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import Foundation

public struct HistoryCommand: AsyncParsableCommand {

    public init() { }

    public static var configuration = CommandConfiguration(
        commandName: "history",
        abstract: "Generate app size history and metrics via App Store Connect.",
        subcommands: [ExportHistoryCommand.self, GraphHistoryCommand.self]
    )
}
