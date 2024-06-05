
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

    /// The metadata provider this logger was created with.
    @inlinable
    public var metadataProvider: Logger.MetadataProvider? {
        return self.handler.metadataProvider
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
                    _ message: @autoclosure () -> Logger.Message,
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
                    _ message: @autoclosure () -> Logger.Message,
                    metadata: @autoclosure () -> Logger.Metadata? = nil,
                    file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.log(level: level, message(), metadata: metadata(), source: nil, file: file, function: function, line: line)
    }

    /// Add, change, or remove a logging metadata item.
    ///
    /// - note: Logging metadata behaves as a value that means a change to the logging metadata will only affect the
    ///         very `Logger` it was changed on.
    @inlinable
    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self.handler[metadataKey: metadataKey]
        }
        set {
            self.handler[metadataKey: metadataKey] = newValue
        }
    }

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

extension Logger {
    /// Log a message passing with the ``Logger/Level/trace`` log level.
    ///
    /// If `.trace` is at least as severe as the `Logger`'s ``logLevel``, it will be logged,
    /// otherwise nothing will happen.
    ///
    /// - parameters:
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message
    ///    - source: The source this log messages originates from. Defaults
    ///              to the module emitting the log message.
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#fileID`.
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    @inlinable
    public func trace(_ message: @autoclosure () -> Logger.Message,
                      metadata: @autoclosure () -> Logger.Metadata? = nil,
                      source: @autoclosure () -> String? = nil,
                      file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.log(level: .trace, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
    }

    /// Log a message passing with the ``Logger/Level/trace`` log level.
    ///
    /// If `.trace` is at least as severe as the `Logger`'s ``logLevel``, it will be logged,
    /// otherwise nothing will happen.
    ///
    /// - parameters:
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#fileID`.
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    @inlinable
    public func trace(_ message: @autoclosure () -> Logger.Message,
                      metadata: @autoclosure () -> Logger.Metadata? = nil,
                      file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.trace(message(), metadata: metadata(), source: nil, file: file, function: function, line: line)
    }

    /// Log a message passing with the ``Logger/Level/debug`` log level.
    ///
    /// If `.debug` is at least as severe as the `Logger`'s ``logLevel``, it will be logged,
    /// otherwise nothing will happen.
    ///
    /// - parameters:
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
    public func debug(_ message: @autoclosure () -> Logger.Message,
                      metadata: @autoclosure () -> Logger.Metadata? = nil,
                      source: @autoclosure () -> String? = nil,
                      file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.log(level: .debug, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
    }

    /// Log a message passing with the ``Logger/Level/debug`` log level.
    ///
    /// If `.debug` is at least as severe as the `Logger`'s ``logLevel``, it will be logged,
    /// otherwise nothing will happen.
    ///
    /// - parameters:
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message.
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#fileID`.
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    @inlinable
    public func debug(_ message: @autoclosure () -> Logger.Message,
                      metadata: @autoclosure () -> Logger.Metadata? = nil,
                      file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.debug(message(), metadata: metadata(), source: nil, file: file, function: function, line: line)
    }

    /// Log a message passing with the ``Logger/Level/info`` log level.
    ///
    /// If `.info` is at least as severe as the `Logger`'s ``logLevel``, it will be logged,
    /// otherwise nothing will happen.
    ///
    /// - parameters:
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
    public func info(_ message: @autoclosure () -> Logger.Message,
                     metadata: @autoclosure () -> Logger.Metadata? = nil,
                     source: @autoclosure () -> String? = nil,
                     file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.log(level: .info, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
    }

    /// Log a message passing with the ``Logger/Level/info`` log level.
    ///
    /// If `.info` is at least as severe as the `Logger`'s ``logLevel``, it will be logged,
    /// otherwise nothing will happen.
    ///
    /// - parameters:
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message.
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#fileID`.
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    @inlinable
    public func info(_ message: @autoclosure () -> Logger.Message,
                     metadata: @autoclosure () -> Logger.Metadata? = nil,
                     file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.info(message(), metadata: metadata(), source: nil, file: file, function: function, line: line)
    }

    /// Log a message passing with the ``Logger/Level/notice`` log level.
    ///
    /// If `.notice` is at least as severe as the `Logger`'s ``logLevel``, it will be logged,
    /// otherwise nothing will happen.
    ///
    /// - parameters:
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
    public func notice(_ message: @autoclosure () -> Logger.Message,
                       metadata: @autoclosure () -> Logger.Metadata? = nil,
                       source: @autoclosure () -> String? = nil,
                       file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.log(level: .notice, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
    }

    /// Log a message passing with the ``Logger/Level/notice`` log level.
    ///
    /// If `.notice` is at least as severe as the `Logger`'s ``logLevel``, it will be logged,
    /// otherwise nothing will happen.
    ///
    /// - parameters:
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
    public func notice(_ message: @autoclosure () -> Logger.Message,
                       metadata: @autoclosure () -> Logger.Metadata? = nil,
                       file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.notice(message(), metadata: metadata(), source: nil, file: file, function: function, line: line)
    }

    /// Log a message passing with the ``Logger/Level/warning`` log level.
    ///
    /// If `.warning` is at least as severe as the `Logger`'s ``logLevel``, it will be logged,
    /// otherwise nothing will happen.
    ///
    /// - parameters:
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
    public func warning(_ message: @autoclosure () -> Logger.Message,
                        metadata: @autoclosure () -> Logger.Metadata? = nil,
                        source: @autoclosure () -> String? = nil,
                        file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.log(level: .warning, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
    }

    /// Log a message passing with the ``Logger/Level/warning`` log level.
    ///
    /// If `.warning` is at least as severe as the `Logger`'s ``logLevel``, it will be logged,
    /// otherwise nothing will happen.
    ///
    /// - parameters:
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message.
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#fileID`.
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    @inlinable
    public func warning(_ message: @autoclosure () -> Logger.Message,
                        metadata: @autoclosure () -> Logger.Metadata? = nil,
                        file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.warning(message(), metadata: metadata(), source: nil, file: file, function: function, line: line)
    }

    /// Log a message passing with the ``Logger/Level/error`` log level.
    ///
    /// If `.error` is at least as severe as the `Logger`'s ``logLevel``, it will be logged,
    /// otherwise nothing will happen.
    ///
    /// - parameters:
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
    public func error(_ message: @autoclosure () -> Logger.Message,
                      metadata: @autoclosure () -> Logger.Metadata? = nil,
                      source: @autoclosure () -> String? = nil,
                      file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.log(level: .error, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
    }

    /// Log a message passing with the ``Logger/Level/error`` log level.
    ///
    /// If `.error` is at least as severe as the `Logger`'s ``logLevel``, it will be logged,
    /// otherwise nothing will happen.
    ///
    /// - parameters:
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message.
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#fileID`.
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    @inlinable
    public func error(_ message: @autoclosure () -> Logger.Message,
                      metadata: @autoclosure () -> Logger.Metadata? = nil,
                      file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.error(message(), metadata: metadata(), source: nil, file: file, function: function, line: line)
    }

    /// Log a message passing with the ``Logger/Level/critical`` log level.
    ///
    /// `.critical` messages will always be logged.
    ///
    /// - parameters:
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
    public func critical(_ message: @autoclosure () -> Logger.Message,
                         metadata: @autoclosure () -> Logger.Metadata? = nil,
                         source: @autoclosure () -> String? = nil,
                         file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.log(level: .critical, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
    }

    /// Log a message passing with the ``Logger/Level/critical`` log level.
    ///
    /// `.critical` messages will always be logged.
    ///
    /// - parameters:
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
    public func critical(_ message: @autoclosure () -> Logger.Message,
                         metadata: @autoclosure () -> Logger.Metadata? = nil,
                         file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.critical(message(), metadata: metadata(), source: nil, file: file, function: function, line: line)
    }
}

/// The `LoggingSystem` is a global facility where the default logging backend implementation (`LogHandler`) can be
/// configured. `LoggingSystem` is set up just once in a given program to set up the desired logging backend
/// implementation.
public enum LoggingSystem {
    private static let _factory = FactoryBox { label, _ in StreamLogHandler.standardError(label: label) }
    private static let _metadataProviderFactory = MetadataProviderBox(nil)

    #if DEBUG
    private static var _warnOnceBox: WarnOnceBox = WarnOnceBox()
    #endif

    /// `bootstrap` is a one-time configuration function which globally selects the desired logging backend
    /// implementation. `bootstrap` can be called at maximum once in any given program, calling it more than once will
    /// lead to undefined behavior, most likely a crash.
    ///
    /// - parameters:
    ///     - factory: A closure that given a `Logger` identifier, produces an instance of the `LogHandler`.
    public static func bootstrap(_ factory: @escaping (String) -> LogHandler) {
        self._factory.replaceFactory({ label, _ in
            factory(label)
        }, validate: true)
    }

    /// `bootstrap` is a one-time configuration function which globally selects the desired logging backend
    /// implementation.
    ///
    /// - Warning:
    /// `bootstrap` can be called at maximum once in any given program, calling it more than once will
    /// lead to undefined behavior, most likely a crash.
    ///
    /// - parameters:
    ///     - metadataProvider: The `MetadataProvider` used to inject runtime-generated metadata from the execution context.
    ///     - factory: A closure that given a `Logger` identifier, produces an instance of the `LogHandler`.
    public static func bootstrap(_ factory: @escaping (String, Logger.MetadataProvider?) -> LogHandler,
                                 metadataProvider: Logger.MetadataProvider?) {
        self._metadataProviderFactory.replaceMetadataProvider(metadataProvider, validate: true)
        self._factory.replaceFactory(factory, validate: true)
    }

    // for our testing we want to allow multiple bootstrapping
    internal static func bootstrapInternal(_ factory: @escaping (String) -> LogHandler) {
        self._metadataProviderFactory.replaceMetadataProvider(nil, validate: false)
        self._factory.replaceFactory({ label, _ in
            factory(label)
        }, validate: false)
    }

    // for our testing we want to allow multiple bootstrapping
    internal static func bootstrapInternal(_ factory: @escaping (String, Logger.MetadataProvider?) -> LogHandler,
                                           metadataProvider: Logger.MetadataProvider?) {
        self._metadataProviderFactory.replaceMetadataProvider(metadataProvider, validate: false)
        self._factory.replaceFactory(factory, validate: false)
    }

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

    #if DEBUG
    /// Used to warn only once about a specific ``LogHandler`` type when it does not support ``Logger/MetadataProvider``,
    /// but an attempt was made to set a metadata provider on such handler. In order to avoid flooding the system with
    /// warnings such warning is only emitted in debug mode, and even then at-most once for a handler type.
    internal static func warnOnceLogHandlerNotSupportedMetadataProvider<Handler: LogHandler>(_ type: Handler.Type) -> Bool {
        self._warnOnceBox.warnOnceLogHandlerNotSupportedMetadataProvider(type: type)
    }
    #endif

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

    /// Construct a `Logger` given a `label` identifying the creator of the `Logger` or a non-standard `LogHandler`.
    ///
    /// The `label` should identify the creator of the `Logger`. This can be an application, a sub-system, or even
    /// a datatype.
    ///
    /// This initializer provides an escape hatch in case the global default logging backend implementation (set up
    /// using `LoggingSystem.bootstrap` is not appropriate for this particular logger.
    ///
    /// - parameters:
    ///     - label: An identifier for the creator of a `Logger`.
    ///     - factory: A closure creating non-standard `LogHandler`s.
    public init(label: String, factory: (String) -> LogHandler) {
        self = Logger(label: label, factory(label))
    }

    /// Construct a `Logger` given a `label` identifying the creator of the `Logger` or a non-standard `LogHandler`.
    ///
    /// The `label` should identify the creator of the `Logger`. This can be an application, a sub-system, or even
    /// a datatype.
    ///
    /// This initializer provides an escape hatch in case the global default logging backend implementation (set up
    /// using `LoggingSystem.bootstrap` is not appropriate for this particular logger.
    ///
    /// - parameters:
    ///     - label: An identifier for the creator of a `Logger`.
    ///     - factory: A closure creating non-standard `LogHandler`s.
    public init(label: String, factory: (String, Logger.MetadataProvider?) -> LogHandler) {
        self = Logger(label: label, factory(label, LoggingSystem.metadataProvider))
    }

    /// Construct a `Logger` given a `label` identifying the creator of the `Logger` and a non-standard ``Logger/MetadataProvider``.
    ///
    /// The `label` should identify the creator of the `Logger`. This can be an application, a sub-system, or even
    /// a datatype.
    ///
    /// This initializer provides an escape hatch in case the global default logging backend implementation (set up
    /// using `LoggingSystem.bootstrap` is not appropriate for this particular logger.
    ///
    /// - parameters:
    ///     - label: An identifier for the creator of a `Logger`.
    ///     - metadataProvider: The custom metadata provider this logger should invoke,
    ///                         instead of the system wide bootstrapped one, when a log statement is about to be emitted.
    public init(label: String, metadataProvider: MetadataProvider) {
        self = Logger(label: label, factory: { label in
            var handler = LoggingSystem.factory(label, metadataProvider)
            handler.metadataProvider = metadataProvider
            return handler
        })
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

// MARK: - Sendable support helpers

extension Logger.MetadataValue: Sendable {}
extension Logger: Sendable {}
extension Logger.Level: Sendable {}
extension Logger.Message: Sendable {}
