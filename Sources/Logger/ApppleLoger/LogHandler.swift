//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Logging API open source project
//
// Copyright (c) 2018-2019 Apple Inc. and the Swift Logging API project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift Logging API project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
import SoftwareEtudesMessages

/// Please note that the above `LogHandler` will still pass the 'log level is a value' test above it iff the global log
/// level has not been overridden. And most importantly it passes the requirement listed above: A change to the log
/// level on one `Logger` should not affect the log level of another `Logger` variable.
public protocol LogHandler: _SwiftLogSendableLogHandler {
    /// The metadata provider this `LogHandler` will use when a log statement is about to be emitted.
    ///

    /// This method is called when a `LogHandler` must emit a log message. There is no need for the `LogHandler` to
    /// check if the `level` is above or below the configured `logLevel` as `Logger` already performed this check and
    /// determined that a message should be logged.
    ///
    /// - parameters:
    ///     - level: The log level the message was logged at.
    ///     - message: The message to log. To obtain a `String` representation call `message.description`.
    ///     - metadata: The metadata associated to this log message.
    ///     - source: The source where the log message originated, for example the logging module.
    ///     - file: The file the log message was emitted from.
    ///     - function: The function the log line was emitted from.
    ///     - line: The line the log message was emitted from.
    func log(level: Logger.Level,
             message: any MessageLog,
             metadata: Logger.Metadata?,
             source: String,
             file: String,
             function: String,
             line: UInt)
    
    
    /// Get or set the configured log level.
    ///
    /// - note: `LogHandler`s must treat the log level as a value type. This means that the change in metadata must
    ///         only affect this very `LogHandler`. It is acceptable to provide some form of global log level override
    ///         that means a change in log level on a particular `LogHandler` might not be reflected in any
    ///        `LogHandler`.
    var logLevel: Logger.Level { get set }
}

// MARK: - Sendable support helpers

@preconcurrency public protocol _SwiftLogSendableLogHandler: Sendable {}
