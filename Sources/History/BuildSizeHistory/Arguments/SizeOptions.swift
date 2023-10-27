//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import Foundation

struct SizeOptions: ParsableArguments {
    init() { }

    @Flag(name: .customLong("download-size"), inversion: .prefixedNo, help: "Include download sizes.")
    var includeDownloadSize = true

    @Flag(name: .customLong("install-size"), inversion: .prefixedNo, help: "Include install sizes.")
    var includeInstallSize = true
}
