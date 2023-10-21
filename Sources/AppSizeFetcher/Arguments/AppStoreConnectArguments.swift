//
//  Copyright © Marc Rollin.
//

import ArgumentParser
import Foundation

// MARK: - AppSizeFetcher

public struct AppStoreConnectArguments: ParsableArguments {
    public init() { }

    @Argument(help: "The key ID from the Apple Developer portal.")
    public var keyID: String

    @Argument(help: "The issuer ID from the App Store Connect organization.")
    public var issuerID: String

    @Argument(help: "The path to the .p8 private key file.")
    public var privateKeyPath: String

    @Argument(help: "The App ID.")
    public var appID: String
}
