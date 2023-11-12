//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import Foundation

// MARK: - AppSizeFetcher

struct AppStoreConnectArguments: ParsableArguments {
    init() { }

    @Argument(help: "The key ID from the Apple Developer portal.")
    var keyID: String

    @Argument(help: "The issuer ID from the App Store Connect organization.")
    var issuerID: String

    @Argument(help: "The path to the .p8 private key file.", transform: URL.init(fileURLWithPath:))
    var privateKey: URL

    @Argument(help: "The App ID.")
    var appID: String
}
