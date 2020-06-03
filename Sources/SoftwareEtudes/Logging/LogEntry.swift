//
//  File.swift
//  
//
//  Created by Georg Tuparev on 30/05/2020.
//

import Foundation

/// The levels are similar to Apple's `os_log` levels. Fatals feels like being a better name and we use it instead
/// of `fault`. `Warning` is additional level. The gap between `error` and `default` is too wide. There are problems
/// that we can fix, but they are worth reporting and taking a special care. This is exactly the case for `warning`.
/// Channeled to `os_log` interface `warnings` perhaps should be converted to `default` logs.
public enum LogLevel {
    case fatal
    case error
    case warning
    case `default`
    case info
    case debug
}

public protocol Logable {

    /// Log level used for filtering log entries by Log Channels
    var level: LogLevel { get }

    /// We use enhanced `os_log` message formats. See complete documentation for complete list
    var message: String? { get }

    /// Many production systems relay on predefines table of error codes. Casual logging does not need codes.
    var code: Int? { get }

    /// If possible, provide human readable localised message. Otherwise returns `message`
    func localizedMessage() -> String
}


/// `LogEntry` provides super simple default implementation of `Logable` protocol.
public struct LogEntry: Logable {
    public private(set) var level: LogLevel
    public private(set) var message: String?
    public private(set) var code: Int?

    func localizedMessage() -> String { message ?? "No message" }
}
