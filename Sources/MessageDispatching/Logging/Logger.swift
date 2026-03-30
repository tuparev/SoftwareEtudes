//
//  Logger.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 18.10.24.
//

import Foundation
import Logging
import SoftwareEtudesCoreMessageDispatching

open class Logger: LogHandler {
    
    public var metadataProvider: Logging.Logger.MetadataProvider?
    public var dispatchers: [MessageDispatching] = []
    public var metadata: Logging.Logger.Metadata
    public var logLevel: Logging.Logger.Level
    
    /// Notification name for process termination - triggers flush on dispatchers
    public static let willTerminateNotification = Notification.Name("SoftwareEtudesLogger.WillTerminate")
    
    private var terminationObserver: NSObjectProtocol?

    // MARK: - Internal Queueing

    /// Stream continuation — thread-safe, `Sendable`, call `yield` from anywhere.
    private let logContinuation: AsyncStream<Log>.Continuation
    private let logStream: AsyncStream<Log>

    /// Retained so flushDispatchers() can await full drain before flushing.
    private var drainTask: Task<Void, Never>?

    public init(logLevel: Logging.Logger.Level = .info, metadata: Logging.Logger.Metadata = [:], dispatchers: [MessageDispatching] = []) {
        self.logLevel = logLevel
        self.metadata = metadata
        self.dispatchers = dispatchers

        var continuation: AsyncStream<Log>.Continuation!
        logStream = AsyncStream<Log> { continuation = $0 }
        logContinuation = continuation

        // Single drain task — processes logs one by one in strict FIFO order.
        // Stored so we can await completion during termination flush.
        let stream = logStream
        drainTask = Task.detached { [weak self] in
            for await log in stream {
                guard let self else { break }
                await self.drain(log)
            }
        }

        terminationObserver = NotificationCenter.default.addObserver(forName: Self.willTerminateNotification, object: nil, queue: nil) { [weak self] _ in
            self?.flushDispatchers()
        }
    }

    deinit {
        logContinuation.finish()
        if let observer = terminationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Swift-Log API

    public func log(level: Logging.Logger.Level,
                    message: Logging.Logger.Message,
                    metadata: Logging.Logger.Metadata?,
                    source: String,
                    file: String,
                    function: String,
                    line: UInt) {

        guard level >= logLevel else { return }

        let log = Log.make(level: level, message: message.description, metadata: metadata,
                           source: source, file: file, function: function, line: line,
                           dispatchers: self.dispatchers)
        logContinuation.yield(log)
    }

    public subscript(metadataKey key: String) -> Logging.Logger.Metadata.Value? {
        get { return metadata[key] }
        set { metadata[key] = newValue }
    }

    // MARK: - Private

    /// Dispatches a single log to all registered dispatchers in order.
    private func drain(_ log: Log) async {
        let message = log.message
        for dispatcher in dispatchers {
            guard dispatcher.dispatcherDelegate?.shouldDispatchMessage(message) ?? true,
                  dispatcher.dispatcherDelegate?.shouldDispatchMessageWithPriority(message.priority) ?? true
            else { continue }
            try? await dispatcher.handle(message)  //TODO: What happens if there is an exception?
        }
    }

    private func flushDispatchers() {
        let semaphore = DispatchSemaphore(value: 0)
        Task.detached { [weak self] in
            guard let self else { semaphore.signal(); return }

            // 1. Stop accepting new logs
            self.logContinuation.finish()

            // 2. Wait for the drain task to finish processing all queued logs
            await self.drainTask?.value

            // 3. Flush each dispatcher's internal buffers
            for dispatcher in self.dispatchers {
                await dispatcher.flushForTermination()
            }

            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + 5.0)
    }
}
