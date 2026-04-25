import Foundation

public protocol Logger: Sendable {
    func log(_ message: String, level: LogLevel)
}

public enum LogLevel: String, Sendable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

public struct ConsoleLogger: Logger {
    public init() {}

    public func log(_ message: String, level: LogLevel = .info) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        print("[\(timestamp)] [\(level.rawValue)] \(message)")
    }
}
