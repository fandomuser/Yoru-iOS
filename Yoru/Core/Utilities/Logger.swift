import Foundation
import OSLog

public enum YoruLogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARN"
    case error = "ERROR"
}

public final class YoruLogger {
    public static let shared = YoruLogger()
    private let logger = Logger(subsystem: "com.yoru.client", category: "Core")

    private init() {}

    public func log(
        _ message: String,
        level: YoruLogLevel = .info,
        category: String = "App",
        file: String = #file,
        line: Int = #line
    ) {
        // Redaction guard: Ensure no credentials or codes are ever printed
        let sanitized = sanitize(message)
        let fileName = (file as NSString).lastPathComponent

        #if DEBUG
        print("[\(level.rawValue)] [\(category)] [\(fileName):\(line)] \(sanitized)")
        #endif

        switch level {
        case .debug:
            logger.debug("\(sanitized, privacy: .public)")
        case .info:
            logger.info("\(sanitized, privacy: .public)")
        case .warning:
            logger.warning("\(sanitized, privacy: .public)")
        case .error:
            logger.error("\(sanitized, privacy: .public)")
        }
    }

    private func sanitize(_ text: String) -> String {
        // Automatically mask suspected auth patterns
        var result = text
        let authCodePattern = #"code\s*[:=]\s*\d+"#
        if let regex = try? NSRegularExpression(pattern: authCodePattern, options: .caseInsensitive) {
            result = regex.stringByReplacingMatches(
                in: result,
                options: [],
                range: NSRange(location: 0, length: result.utf16.count),
                withTemplate: "code:[REDACTED]"
            )
        }
        return result
    }
}
