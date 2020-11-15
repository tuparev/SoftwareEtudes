//
//  LogEntry.swift
//  
//
//  Created by Georg Tuparev on 30/05/2020.
//
//  Contributions, suggestions, ideas by:
//      1. Tomi Engel - @tomi_engel

import Foundation

/// Log Levels
///
/// Log levels are ordered by their severity, with `.trace` being the least severe and `.critical` being the most severe.
/// They are also `Int`s to allow to compare them.
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

    /// Nothing to wary too much but worth noticing.
    case notice = 3

    /// Appropriate for messages that are not error conditions yet, but more severe than `.notice`.
    case warning = 4

    /// Something really went wrong, but execution might continue (with caution).
    case error = 5

    /// Boom! A critical error conditions was encounter. After handling the LogEntry, it is recommended to terminate
    /// further program execution.
    /// When a `critical` message is logged, the logging machinery should perform domain specific operations to capture
    /// system state (such as capturing stack traces) to facilitate debugging. The logger might also decide to terminate
    /// the process. The log channels should be flushed before terminating the process.
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

/// `LogPersistencyPeriodHint` is a hint for the `Logger` and the `LogChannel` if the log should be made persistent and
/// if yes, for how long.
///
/// It is recommended all cases with negative `rawValue` to be transient. The persistency of`longTermAuto` should be
/// defined by the module handling the `LogEntries`. It is recommended all cases with a positive `rawValue` to be stored
/// at least as many days as the `rawValue` (if the system resources allow, e.g. size of rotating log files). The
/// `longTermForever` should be defined by the module handling the `LogEntries` (e.g. might be added to operation
/// database etc.).
public enum LogPersistencyPeriodHint: Int, Codable {
    case undefined       = -99
    case metadata        = -10
    case shortTerm       = -1
    case longTermAuto    = 0
    case longTerm1       = 1
    case longTerm3       = 3
    case longTerm7       = 7
    case longTerm14      = 14
    case longTerm30      = 30
    case longTermForever = 9999

    public func isTransient() -> Bool { self.rawValue < 0 }
}

/// Logs a point of interest in the code
///
///  Signposts help to measure time intervals or interesting event for debugging and performance monitoring.  Signpost
/// groups (surrounded by `.begin` and `.end` events could be nested. The `rawValues` within a signpost group should
/// be the same unique string (e.g. UUID).
///
/// To facilitate `Codable` the unique string should have a signpost type prefix: `@begin:`, `@event:`, or `@end:`.
public enum SignpostLogType: Codable, CustomStringConvertible {
    case begin(String)
    case event(String)
    case end(String)

    public init(from decoder: Decoder) throws {
        if let value = try? String(from: decoder) {
            if      value.hasPrefix("@begin:") { self  = .begin(value) }
            else if value.hasPrefix("@event:") { self  = .event(value) }
            else if value.hasPrefix("@end:")   { self  = .end(value) }
            else {
                let context = DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Missing decoding info: @begin, @event:, or @end")
                throw DecodingError.dataCorrupted(context)

            }
        }
        else {
            let context = DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Cannot decode \(String.self)")
            throw DecodingError.dataCorrupted(context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
            case .begin(let key): try container.encode(String("@begin:\(key))"))
            case .event(let key): try container.encode(String("@event:\(key))"))
            case .end(let key):   try container.encode(String("@end:\(key))"))
        }
    }

    public var description: String {
        switch self {
            case .begin: return "@begin:\(self))"
            case .event: return "@event:\(self))"
            case .end:   return "@end:\(self))"
        }
    }
}

/// `Logable` defines a `LogEntry`
///
/// Most logging frameworks define a `LogEntry` type as struct. This imposes restrictions on the complex packages
/// adopting the logging framework because the `LogEntry` cannot be substituted.
public protocol Logable {

    /// Log level used for filtering log entries by Log Channels
    var level: LogLevel { get }

    /// A suggestion how long the LogEntry receiving system should keep it persistent
    var persistencyHint: LogPersistencyPeriodHint { get }

    /// Is this a signpost (performance measuring or debugging) LogEntry? The raw value of the signpost is the ID
    var signpost: SignpostLogType? { get }

    /// The fastest and most compact way to create a message is by using the message code. The message interpreter
    /// (possibly part of another process) should take the burden of interpreting, localising, formatting, and optionally -
    /// storing for further processing the message (as part of the Log Entry).
    var message: Messaging { get }

    /// The time of the log entry. It makes no sense to be different than the creation time and this should be reflected
    /// in the initialiser.
    var timestamp: Date { get }

    /// If present, it is recommended that the `domain` is in reverse DNS format (e.g. com.example.myapp.ui)
    var domain: String? { get }

    /// An optional dictionary. Most probably will be used for things like __FILE__ and __LINE__
    var userInfo: [String : String]? { get }
}


/// `LogEntry` provides super simple default implementation of `Logable` protocol.
public struct LogEntry: Logable {
    public let level: LogLevel = .notice
    public let persistencyHint: LogPersistencyPeriodHint = .longTermAuto
    public let signpost: SignpostLogType? = nil
    public let message: Messaging
    public let timestamp = Date()
    public let domain: String?
    public let userInfo: [String : String]?
}
