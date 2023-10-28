//
//  Copyright © Marc Rollin.
//

import Foundation
import Rainbow

public enum Console {

    // MARK: Public

    public static func configure(options: ConsoleOptions) {
        verbose = options.verbose
        silence = options.silence
    }

    public static func debug(_ message: any StringProtocol, prefix: String? = nil) {
        log(.debug, message, prefix: prefix)
    }

    public static func info(_ message: any StringProtocol, prefix: String? = nil) {
        log(.info, message, prefix: prefix)
    }

    public static func notice(_ message: any StringProtocol, prefix: String? = nil) {
        log(.notice, message, prefix: prefix)
    }

    public static func success(_ message: any StringProtocol, prefix: String? = nil) {
        log(.success, message, prefix: prefix)
    }

    public static func warn(_ message: any StringProtocol, prefix: String? = nil) {
        log(.warn, message, prefix: prefix)
    }

    public static func error(_ message: any StringProtocol, prefix: String? = nil) {
        log(.error, message, prefix: prefix)
    }

    public static func progress(_ progress: Float, columns: Int) -> String {
        let completedBars = lroundf(progress * Float(columns))
        let remainingBars = columns - completedBars
        let formattedPercentage = "\(lroundf(progress * 100))%"
        let paddingForPercentage = 5 - formattedPercentage.count
        let completedSection = String(repeating: "=", count: completedBars)
        let remainingSection = String(repeating: " ", count: remainingBars)
        let percentagePadding = String(repeating: " ", count: paddingForPercentage)
        let status = progress < 1 ? "↕️" : "✅"
        return "[\(completedSection)\(remainingSection)]\(percentagePadding)\(formattedPercentage) \(status)"
    }

    // MARK: Private

    private enum Level {
        case debug, info, notice, success, warn, error
    }

    private static var verbose = false
    private static var silence = false

    private static func log(_ level: Level, _ message: any StringProtocol, prefix: String? = nil) {
        guard !silence else { return }
        let prefix = prefix ?? ""
        switch level {
        case .debug where verbose:
            print("\(prefix)\(String(message).magenta)")
        case .info:
            print("\(prefix)\(String(message))")
        case .notice:
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
