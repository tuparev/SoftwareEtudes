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

#if canImport(Darwin)
import Darwin
#endif
import SoftwareEtudesMessages

public typealias EtudeMessage = SoftwareEtudesMessages.Message

/// A `Logger` is the central type in `SwiftLog`. Its central function is to emit log messages using one of the methods
/// corresponding to a log level.
///
/// `Logger`s are value types with respect to the ``logLevel`` and the ``metadata`` (as well as the immutable `label`
/// and the selected ``LogHandler``). Therefore, `Logger`s are suitable to be passed around between libraries if you want
/// to preserve metadata across libraries.
///
/// The most basic usage of a `Logger` is
///
/// ```swift
/// logger.info("Hello World!")
/// ```
public struct Logger {
    /// Storage class to hold the label and log handler
    @usableFromInline
    internal final class Storage: @unchecked /* and not actually */ Sendable /* but safe if only used with CoW */ {
        @usableFromInline
        var label: String

        @usableFromInline
        var handler: LogHandler

        @inlinable
        init(label: String, handler: LogHandler) {
            self.label = label
            self.handler = handler
        }

        @inlinable
        func copy() -> Storage {
            return Storage(label: self.label, handler: self.handler)
        }
    }

    @usableFromInline
    internal var _storage: Storage
    public var label: String {
        return self._storage.label
    }

    /// A computed property to access the `LogHandler`.
    @inlinable
    public var handler: LogHandler {
        get {
            return self._storage.handler
        }
        set {
            if !isKnownUniquelyReferenced(&self._storage) {
                self._storage = self._storage.copy()
            }
            self._storage.handler = newValue
        }
    }

    @usableFromInline
    internal init(label: String, _ handler: LogHandler) {
        self._storage = Storage(label: label, handler: handler)
    }
}

extension Logger {
    /// Log a message passing the log level as a parameter.
    ///
    /// If the `logLevel` passed to this method is more severe than the `Logger`'s ``logLevel``, it will be logged,
    /// otherwise nothing will happen.
    ///
    /// - parameters:
    ///    - level: The log level to log `message` at. For the available log levels, see `Logger.Level`.
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message.
    ///    - source: The source this log messages originates from. Defaults
    ///              to the module emitting the log message.
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#fileID`.
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    @inlinable
    public func log(level: Logger.Level,
                    _ message: @autoclosure () -> any MessageLog,
                    metadata: @autoclosure () -> Logger.Metadata? = nil,
                    source: @autoclosure () -> String? = nil,
                    file: String = #fileID, function: String = #function, line: UInt = #line) {
        if self.logLevel <= level {
            self.handler.log(level: level,
                             message: message(),
                             metadata: metadata(),
                             source: source() ?? Logger.currentModule(fileID: (file)),
                             file: file, function: function, line: line)
        }
    }

    /// Log a message passing the log level as a parameter.
    ///
    /// If the ``logLevel`` passed to this method is more severe than the `Logger`'s ``logLevel``, it will be logged,
    /// otherwise nothing will happen.
    ///
    /// - parameters:
    ///    - level: The log level to log `message` at. For the available log levels, see `Logger.Level`.
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message.
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#fileID`.
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    @inlinable
    public func log(level: Logger.Level,
                    _ message: @autoclosure () -> any MessageLog,
                    metadata: @autoclosure () -> Logger.Metadata? = nil,
                    file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.log(level: level, message(), metadata: metadata(), source: nil, file: file, function: function, line: line)
    }
    
//    @inlinable
//    public func log(level: Logger.Level,
//                    _ message: @autoclosure () -> EtudeMessage,
//                    metadata: @autoclosure () -> Logger.Metadata? = nil,
//                    file: String = #fileID, function: String = #function, line: UInt = #line) {
//        self.log(level: level, message(), metadata: metadata(), source: nil, file: file, function: function, line: line)
//    }

    /// Get or set the log level configured for this `Logger`.
    ///
    /// - note: `Logger`s treat `logLevel` as a value. This means that a change in `logLevel` will only affect this
    ///         very `Logger`. It is acceptable for logging backends to have some form of global log level override
    ///         that affects multiple or even all loggers. This means a change in `logLevel` to one `Logger` might in
    ///         certain cases have no effect.
    @inlinable
    public var logLevel: Logger.Level {
        get {
            return self.handler.logLevel
        }
        set {
            self.handler.logLevel = newValue
        }
    }
}

/// The `LoggingSystem` is a global facility where the default logging backend implementation (`LogHandler`) can be
/// configured. `LoggingSystem` is set up just once in a given program to set up the desired logging backend
/// implementation.
public enum LoggingSystem {
    private static let _factory = FactoryBox { label, _ in StreamLogHandler.standardError(label: label) }
    private static let _metadataProviderFactory = MetadataProviderBox(nil)

    fileprivate static var factory: (String, Logger.MetadataProvider?) -> LogHandler {
        return { label, metadataProvider in
            self._factory.underlying(label, metadataProvider)
        }
    }

    /// System wide ``Logger/MetadataProvider`` that was configured during the logging system's `bootstrap`.
    ///
    /// When creating a ``Logger`` using the plain ``Logger/init(label:)`` initializer, this metadata provider
    /// will be provided to it.
    ///
    /// When using custom log handler factories, make sure to provide the bootstrapped metadata provider to them,
    /// or the metadata will not be filled in automatically using the provider on log-sites. While using a custom
    /// factory to avoid using the bootstrapped metadata provider may sometimes be useful, usually it will lead to
    /// un-expected behavior, so make sure to always propagate it to your handlers.
    public static var metadataProvider: Logger.MetadataProvider? {
        return self._metadataProviderFactory.metadataProvider
    }

    private final class FactoryBox {
        private let lock = ReadWriteLock()
        fileprivate var _underlying: (_ label: String, _ provider: Logger.MetadataProvider?) -> LogHandler
        private var initialized = false

        init(_ underlying: @escaping (String, Logger.MetadataProvider?) -> LogHandler) {
            self._underlying = underlying
        }

        func replaceFactory(_ factory: @escaping (String, Logger.MetadataProvider?) -> LogHandler, validate: Bool) {
            self.lock.withWriterLock {
                precondition(!validate || !self.initialized, "logging system can only be initialized once per process.")
                self._underlying = factory
                self.initialized = true
            }
        }

        var underlying: (String, Logger.MetadataProvider?) -> LogHandler {
            return self.lock.withReaderLock {
                return self._underlying
            }
        }
    }

    private final class MetadataProviderBox {
        private let lock = ReadWriteLock()

        internal var _underlying: Logger.MetadataProvider?
        private var initialized = false

        init(_ underlying: Logger.MetadataProvider?) {
            self._underlying = underlying
        }

        func replaceMetadataProvider(_ metadataProvider: Logger.MetadataProvider?, validate: Bool) {
            self.lock.withWriterLock {
                precondition(!validate || !self.initialized, "logging system can only be initialized once per process.")
                self._underlying = metadataProvider
                self.initialized = true
            }
        }

        var metadataProvider: Logger.MetadataProvider? {
            return self.lock.withReaderLock {
                return self._underlying
            }
        }
    }
}

extension Logger {
    /// `Metadata` is a typealias for `[String: Logger.MetadataValue]` the type of the metadata storage.
    public typealias Metadata = [String: MetadataValue]

    /// A logging metadata value. `Logger.MetadataValue` is string, array, and dictionary literal convertible.
    ///
    /// `MetadataValue` provides convenient conformances to `ExpressibleByStringInterpolation`,
    /// `ExpressibleByStringLiteral`, `ExpressibleByArrayLiteral`, and `ExpressibleByDictionaryLiteral` which means
    /// that when constructing `MetadataValue`s you should default to using Swift's usual literals.
    ///
    /// Examples:
    ///  - prefer `logger.info("user logged in", metadata: ["user-id": "\(user.id)"])` over
    ///    `..., metadata: ["user-id": .string(user.id.description)])`
    ///  - prefer `logger.info("user selected colors", metadata: ["colors": ["\(user.topColor)", "\(user.secondColor)"]])`
    ///    over `..., metadata: ["colors": .array([.string("\(user.topColor)"), .string("\(user.secondColor)")])`
    ///  - prefer `logger.info("nested info", metadata: ["nested": ["fave-numbers": ["\(1)", "\(2)", "\(3)"], "foo": "bar"]])`
    ///    over `..., metadata: ["nested": .dictionary(["fave-numbers": ...])])`
    public enum MetadataValue {
        /// A metadata value which is a `String`.
        ///
        /// Because `MetadataValue` implements `ExpressibleByStringInterpolation`, and `ExpressibleByStringLiteral`,
        /// you don't need to type `.string(someType.description)` you can use the string interpolation `"\(someType)"`.
        case string(String)

        /// A metadata value which is some `CustomStringConvertible`.
        case stringConvertible(CustomStringConvertible & Sendable)

        /// A metadata value which is a dictionary from `String` to `Logger.MetadataValue`.
        ///
        /// Because `MetadataValue` implements `ExpressibleByDictionaryLiteral`, you don't need to type
        /// `.dictionary(["foo": .string("bar \(buz)")])`, you can just use the more natural `["foo": "bar \(buz)"]`.
        case dictionary(Metadata)

        /// A metadata value which is an array of `Logger.MetadataValue`s.
        ///
        /// Because `MetadataValue` implements `ExpressibleByArrayLiteral`, you don't need to type
        /// `.array([.string("foo"), .string("bar \(buz)")])`, you can just use the more natural `["foo", "bar \(buz)"]`.
        case array([Metadata.Value])
    }

    /// The log level.
    ///
    /// Log levels are ordered by their severity, with `.trace` being the least severe and
    /// `.critical` being the most severe.
    public enum Level: String, Codable, CaseIterable {
        /// Appropriate for messages that contain information normally of use only when
        /// tracing the execution of a program.
        case trace

        /// Appropriate for messages that contain information normally of use only when
        /// debugging a program.
        case debug

        /// Appropriate for informational messages.
        case info

        /// Appropriate for conditions that are not error conditions, but that may require
        /// special handling.
        case notice

        /// Appropriate for messages that are not error conditions, but more severe than
        /// `.notice`.
        case warning

        /// Appropriate for error conditions.
        case error

        /// Appropriate for critical error conditions that usually require immediate
        /// attention.
        ///
        /// When a `critical` message is logged, the logging backend (`LogHandler`) is free to perform
        /// more heavy-weight operations to capture system state (such as capturing stack traces) to facilitate
        /// debugging.
        case critical
    }

    /// Construct a `Logger` given a `label` identifying the creator of the `Logger`.
    ///
    /// The `label` should identify the creator of the `Logger`. This can be an application, a sub-system, or even
    /// a datatype.
    ///
    /// - parameters:
    ///     - label: An identifier for the creator of a `Logger`.
    public init(label: String) {
        self.init(label: label, LoggingSystem.factory(label, LoggingSystem.metadataProvider))
    }
}

extension Logger.Level {
    internal var naturalIntegralValue: Int {
        switch self {
        case .trace:
            return 0
        case .debug:
            return 1
        case .info:
            return 2
        case .notice:
            return 3
        case .warning:
            return 4
        case .error:
            return 5
        case .critical:
            return 6
        }
    }
}

extension Logger.Level: Comparable {
    public static func < (lhs: Logger.Level, rhs: Logger.Level) -> Bool {
        return lhs.naturalIntegralValue < rhs.naturalIntegralValue
    }
}

extension Logger {
    /// `Logger.Message` represents a log message's text. It is usually created using string literals.
    ///
    /// Example creating a `Logger.Message`:
    ///
    ///     let world: String = "world"
    ///     let myLogMessage: Logger.Message = "Hello \(world)"
    ///
    /// Most commonly, `Logger.Message`s appear simply as the parameter to a logging method such as:
    ///
    ///     logger.info("Hello \(world)")
    ///
    public struct Message: ExpressibleByStringLiteral, Equatable, CustomStringConvertible, ExpressibleByStringInterpolation, MessageLog {
        public typealias StringLiteralType = String

        private var value: String

        public init(stringLiteral value: String) {
            self.value = value
        }

        public var description: String {
            return self.value
        }
    }
}

#if canImport(WASILibc) || os(Android)
internal typealias CFilePointer = OpaquePointer
#else
internal typealias CFilePointer = UnsafeMutablePointer<FILE>
#endif

/// A wrapper to facilitate `print`-ing to stderr and stdio that
/// ensures access to the underlying `FILE` is locked to prevent
/// cross-thread interleaving of output.
internal struct StdioOutputStream: TextOutputStream {
    internal let file: CFilePointer
    internal let flushMode: FlushMode

    internal func write(_ string: String) {
        self.contiguousUTF8(string).withContiguousStorageIfAvailable { utf8Bytes in
            #if os(Windows)
            _lock_file(self.file)
            #elseif canImport(WASILibc)
            // no file locking on WASI
            #else
            flockfile(self.file)
            #endif
            defer {
                #if os(Windows)
                _unlock_file(self.file)
                #elseif canImport(WASILibc)
                // no file locking on WASI
                #else
                funlockfile(self.file)
                #endif
            }
            _ = fwrite(utf8Bytes.baseAddress!, 1, utf8Bytes.count, self.file)
            if case .always = self.flushMode {
                self.flush()
            }
        }!
    }

    /// Flush the underlying stream.
    /// This has no effect when using the `.always` flush mode, which is the default
    internal func flush() {
        _ = fflush(self.file)
    }

    internal func contiguousUTF8(_ string: String) -> String.UTF8View {
        var contiguousString = string
        contiguousString.makeContiguousUTF8()
        return contiguousString.utf8
    }

    internal static let stderr = StdioOutputStream(file: systemStderr, flushMode: .always)
    internal static let stdout = StdioOutputStream(file: systemStdout, flushMode: .always)

    /// Defines the flushing strategy for the underlying stream.
    internal enum FlushMode {
        case undefined
        case always
    }
}

// Prevent name clashes
#if canImport(Darwin)
let systemStderr = Darwin.stderr
let systemStdout = Darwin.stdout

#endif

/// `StreamLogHandler` is a simple implementation of `LogHandler` for directing
/// `Logger` output to either `stderr` or `stdout` via the factory methods.
///
/// Metadata is merged in the following order:
/// 1. Metadata set on the log handler itself is used as the base metadata.
/// 2. The handler's ``metadataProvider`` is invoked, overriding any existing keys.
/// 3. The per-log-statement metadata is merged, overriding any previously set keys.
public struct StreamLogHandler: LogHandler {
    internal typealias _SendableTextOutputStream = TextOutputStream & Sendable

    /// Factory that makes a `StreamLogHandler` to directs its output to `stdout`
    public static func standardOutput(label: String) -> StreamLogHandler {
        return StreamLogHandler(label: label, stream: StdioOutputStream.stdout, metadataProvider: LoggingSystem.metadataProvider)
    }

    /// Factory that makes a `StreamLogHandler` that directs its output to `stdout`
    public static func standardOutput(label: String, metadataProvider: Logger.MetadataProvider?) -> StreamLogHandler {
        return StreamLogHandler(label: label, stream: StdioOutputStream.stdout, metadataProvider: metadataProvider)
    }

    /// Factory that makes a `StreamLogHandler` that directs its output to `stderr`
    public static func standardError(label: String) -> StreamLogHandler {
        return StreamLogHandler(label: label, stream: StdioOutputStream.stderr, metadataProvider: LoggingSystem.metadataProvider)
    }

    /// Factory that makes a `StreamLogHandler` that direct its output to `stderr`
    public static func standardError(label: String, metadataProvider: Logger.MetadataProvider?) -> StreamLogHandler {
        return StreamLogHandler(label: label, stream: StdioOutputStream.stderr, metadataProvider: metadataProvider)
    }

    private let stream: _SendableTextOutputStream
    private let label: String

    public var logLevel: Logger.Level = .info

    public var metadataProvider: Logger.MetadataProvider?

    private var prettyMetadata: String?
    public var metadata = Logger.Metadata() {
        didSet {
            self.prettyMetadata = self.prettify(self.metadata)
        }
    }

    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self.metadata[metadataKey]
        }
        set {
            self.metadata[metadataKey] = newValue
        }
    }

    // internal for testing only
    internal init(label: String, stream: _SendableTextOutputStream) {
        self.init(label: label, stream: stream, metadataProvider: LoggingSystem.metadataProvider)
    }

    // internal for testing only
    internal init(label: String, stream: _SendableTextOutputStream, metadataProvider: Logger.MetadataProvider?) {
        self.label = label
        self.stream = stream
        self.metadataProvider = metadataProvider
    }

    public func log(level: Logger.Level,
                    message: any MessageLog,
                    metadata explicitMetadata: Logger.Metadata?,
                    source: String,
                    file: String,
                    function: String,
                    line: UInt) {
        let effectiveMetadata = StreamLogHandler.prepareMetadata(base: self.metadata, provider: self.metadataProvider, explicit: explicitMetadata)

        let prettyMetadata: String?
        if let effectiveMetadata = effectiveMetadata {
            prettyMetadata = self.prettify(effectiveMetadata)
        } else {
            prettyMetadata = self.prettyMetadata
        }

        var stream = self.stream
        stream.write("\(self.timestamp()) \(level) \(self.label) :\(prettyMetadata.map { " \($0)" } ?? "") [\(source)] \(message)\n")
    }

    internal static func prepareMetadata(base: Logger.Metadata, provider: Logger.MetadataProvider?, explicit: Logger.Metadata?) -> Logger.Metadata? {
        var metadata = base

        let provided = provider?.get() ?? [:]

        guard !provided.isEmpty || !((explicit ?? [:]).isEmpty) else {
            // all per-log-statement values are empty
            return nil
        }

        if !provided.isEmpty {
            metadata.merge(provided, uniquingKeysWith: { _, provided in provided })
        }

        if let explicit = explicit, !explicit.isEmpty {
            metadata.merge(explicit, uniquingKeysWith: { _, explicit in explicit })
        }

        return metadata
    }

    private func prettify(_ metadata: Logger.Metadata) -> String? {
        if metadata.isEmpty {
            return nil
        } else {
            return metadata.lazy.sorted(by: { $0.key < $1.key }).map { "\($0)=\($1)" }.joined(separator: " ")
        }
    }

    private func timestamp() -> String {
        var buffer = [Int8](repeating: 0, count: 255)
        #if os(Windows)
        var timestamp = __time64_t()
        _ = _time64(&timestamp)

        var localTime = tm()
        _ = _localtime64_s(&localTime, &timestamp)

        _ = strftime(&buffer, buffer.count, "%Y-%m-%dT%H:%M:%S%z", &localTime)
        #else
        var timestamp = time(nil)
        guard let localTime = localtime(&timestamp) else {
            return "<unknown>"
        }
        strftime(&buffer, buffer.count, "%Y-%m-%dT%H:%M:%S%z", localTime)
        #endif
        return buffer.withUnsafeBufferPointer {
            $0.withMemoryRebound(to: CChar.self) {
                String(cString: $0.baseAddress!)
            }
        }
    }
}

extension Logger {
    @inlinable
    internal static func currentModule(filePath: String = #file) -> String {
        let utf8All = filePath.utf8
        return filePath.utf8.lastIndex(of: UInt8(ascii: "/")).flatMap { lastSlash -> Substring? in
            utf8All[..<lastSlash].lastIndex(of: UInt8(ascii: "/")).map { secondLastSlash -> Substring in
                filePath[utf8All.index(after: secondLastSlash) ..< lastSlash]
            }
        }.map {
            String($0)
        } ?? "n/a"
    }

    @inlinable
    internal static func currentModule(fileID: String = #fileID) -> String {
        let utf8All = fileID.utf8
        if let slashIndex = utf8All.firstIndex(of: UInt8(ascii: "/")) {
            return String(fileID[..<slashIndex])
        } else {
            return "n/a"
        }
    }
}
