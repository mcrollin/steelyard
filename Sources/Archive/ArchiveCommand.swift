//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import Foundation

public struct ArchiveCommand: AsyncParsableCommand {

    public init() { }

    public static var configuration = CommandConfiguration(
        commandName: "archive",
        abstract: "Deep-dive into the size components of an app archive.",
        subcommands: [InspectBuildCommand.self, AnalyzeBuildCommand.self]
    )
}
