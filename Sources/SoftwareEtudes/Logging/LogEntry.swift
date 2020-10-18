//
//  LogEntry.swift
//  
//
//  Created by Georg Tuparev on 30/05/2020.
//
//  Contributions, suggestions, ideas by:
//      1. Tomi Engel - @tomi_engel

import Foundation

/// Software Etudes' Logging is different than SwiftLog!
///
/// How?
/// - It is simpler. No excessive use of Swift modernism. Our goal is to have simple and readable logging system that just works.
/// - It allows complex client-server implementations. If needed, Etude's logging system could be used in high-performance, complex
/// systems allowing near-realtime non-intrusive logging.
/// - It could be use as trace-logger to measure time-critical processes.
/// - It supports persistency.
/// - If required, user's privacy could be protected.
/// - Log messages are localisable (yes, English is not the only language!).
/// - Handling log entries could be handled after time-critical processes/threads are executed.
/// - Whenever possible, it integrates with other logging systems.
/// - Could be integrated as part of domain specific logging systems.
/// - It is fun to use!
///
///
/// Software Etudes' Logging is similar with SwiftLog!
///
/// How?
/// - Uses the same log levels
/// - Whenever possible, uses same method names and equivalent types, so it makes it easy to be adopted with minimal refactoring.


/// Log Levels
///
/// Log levels are ordered by their severity, with `.trace` being the least severe and `.critical` being the most severe.
/// They are also `Int`s to allow to compare them.
///
/// It is recommended, that loggers will persist LogEntries with level `notice` of higher at least for some time.
///
/// The levels are the same as `SwiftLog` levels. But the LogLevel enum type is different!
///
public enum LogLevel: Int, Codable, CustomStringConvertible, CaseIterable {

    /// Use this for tracing (time or execution  flow) of the process. Note that LogEntries could be made available
    /// asynchronously at later stage. Use proper (visualisation) tools to create trace graph.
    case trace = 0

    /// Appropriate for messages that contain information to facilitate debugging of a program, often equivalent to
    /// print() function calls.
    case debug = 1

    /// Appropriate for informational messages, often revealing the content of objects or structures.
    case info = 2

    /// Nothing to wary too much but worth noticing, specially in early or experimental stages. It is recommended to
    /// make `notice`s and higher level LogEntries persistent.
    case notice = 3

    /// Appropriate for messages that are not error conditions yet, but more severe than `.notice`.
    case warning = 4

    /// Something really went wrong, but execution might continue (with caution).
    case error = 5

    /// Boom! A critical error conditions was encounter. After handling the LogEntry, it is recommended to terminate
    /// further program execution.
    ///
    /// When a `critical` message is logged, the logging machinery should perform domain specific operations to capture
    /// system state (such as capturing stack traces) to facilitate debugging. The logger might also decide to terminate
    /// the process.
    case critical = 6

    public var description: String {
        switch self {
            case .trace:    return "trace"
            case .debug:    return "debug"
            case .info:     return "info"
            case .notice:   return "notice"
            case .warning:  return "warning"
            case .error:    return "error"
            case .critical: return "critical"
        }
    }
}

public protocol Logable {

    /// Log level used for filtering log entries by Log Channels
    var level: LogLevel { get }

    /// The fastest and most compact way to create a message is by using the message code. The message interpreter
    /// (possibly part of another process) should take the burden of interpreting, localising, formatting, and optionally -
    /// storing for further processing the message (as part of the Log Entry).
    var message: Messaging? { get }

    /// The time of the log entry. It makes no sense to be different than the creation time and this should be reflected
    /// in the initialiser.
    var timestamp: Date { get }

    var domain: String? { get }

    /// An optional dictionary. Most probably will be used for things like __FILE__ and __LINE__
    var userInfo: [String : String]? { get }
}


/// `LogEntry` provides super simple default implementation of `Logable` protocol.
public struct LogEntry: Logable {
    public let level: LogLevel = .notice
    public let message: Messaging?
    public let timestamp = Date()
    public let domain: String?
    public let userInfo: [String : String]?
}
