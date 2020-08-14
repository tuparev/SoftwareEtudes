//
//  LogEntry.swift
//  
//
//  Created by Georg Tuparev on 30/05/2020.
//
//  Contributions, suggestions, ideas by:
//      1. Tomi Engel - @tomi_engel

import Foundation

/// The levels are the same as `SwiftLog` levels.
public enum LogLevel {
    case trace
    case debug
    case info
    case notice
    case warning
    case error
    case critical
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
    public private(set) var level: LogLevel = .`default`
    public private(set) var message: String?
    public private(set) var code: Int?
    
    public let timestamp = Date()

    public func localizedMessage() -> String { message ?? "No message" }
}
