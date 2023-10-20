//
//  Copyright © Marc Rollin.
//

import Foundation
import Rainbow

enum Console {

    // MARK: Internal

    static var verbose = false

    static func debug(_ message: any StringProtocol, prefix: String? = nil) {
        log(.debug, message, prefix: prefix)
    }

    static func info(_ message: any StringProtocol, prefix: String? = nil) {
        log(.info, message, prefix: prefix)
    }

    static func success(_ message: any StringProtocol, prefix: String? = nil) {
        log(.success, message, prefix: prefix)
    }

    static func warn(_ message: any StringProtocol, prefix: String? = nil) {
        log(.warn, message, prefix: prefix)
    }

    static func error(_ message: any StringProtocol, prefix: String? = nil) {
        log(.error, message, prefix: prefix)
    }

    static func progress(_ progress: Float, columns: Int) -> String {
        let completedBars = lroundf(progress * Float(columns))
        let remainingBars = columns - completedBars
        let formattedPercentage = "\(lroundf(progress * 100))%"
        let paddingForPercentage = 5 - formattedPercentage.count
        let completedSection = String(repeating: "=", count: completedBars)
        let remainingSection = String(repeating: " ", count: remainingBars)
        let percentagePadding = String(repeating: " ", count: paddingForPercentage)
        return "[\(completedSection)\(remainingSection)]\(percentagePadding)\(formattedPercentage)"
    }

    // MARK: Private

    private enum Level {
        case debug, info, success, warn, error
    }

    private static func log(_ level: Level, _ message: any StringProtocol, prefix: String? = nil) {
        let prefix = prefix ?? ""
        switch level {
        case .debug where verbose:
            print("\(prefix)\(String(message))")
        case .info where verbose:
            print("\(prefix)\(String(message).blue)")
        case .success:
            print("\(prefix)\(String(message).bold.green)")
        case .warn:
            print("\(prefix)\(String(message).bold.yellow)")
        case .error:
            print("\(prefix)\(String(message).bold.red)")
        default:
            break
        }
    }
}
