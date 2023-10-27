//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import Foundation

public struct BuildCommand: AsyncParsableCommand {

    public init() { }

    public static var configuration = CommandConfiguration(
        commandName: "build",
        abstract: "Deep-dive into the size components of a specific app build.",
        subcommands: [InspectBuildCommand.self, AnalyzeBuildCommand.self]
    )
}
