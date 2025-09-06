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

    public init(logLevel: Logging.Logger.Level = .info, metadata: Logging.Logger.Metadata = [:], dispatchers: [MessageDispatching] = []) {
        self.logLevel = logLevel
        self.metadata = metadata
        self.dispatchers = dispatchers
    }
    
    // MARK: - Swift-Log API (zero-cost disabled logs)
    public func log(level: Logging.Logger.Level,
                    message: Logging.Logger.Message,
                    metadata: Logging.Logger.Metadata?,
                    source: String,
                    file: String,
                    function: String,
                    line: UInt) {
    
        // 1) Global level gate
        guard level >= logLevel else { return }
        
        // 2) Use the factory to build a Log
        let log = Log.make(level: level, message: message.description, metadata: metadata, source: source,file: file,
                             function: function, line: line, dispatchers: self.dispatchers)
        
        // 3) Enqueue & trigger the drain
        queue.async { [weak self] in
            guard let self = self else { return }
            self.logQueue.append(log)
            self.handleLogQueue()
        }
    }
    
    public subscript(metadataKey key: String) -> Logging.Logger.Metadata.Value? {
        get { return metadata[key] }
        set { metadata[key] = newValue }
    }
    
    // MARK: - Internal Queueing
    /// Serial queue for synchronising access to `messageQueue`.
    private let queue = DispatchQueue(label: "com.SoftwareEtudes.logger.queue")
    /// In-memory buffer of Logs awaiting dispatch.
    private var logQueue: [Log] = []
    
    private func handleLogQueue() {
        
        // 1) Snapshot & clear (we're already inside the queue, so no need for sync)
        let logs = self.logQueue
        self.logQueue.removeAll()
        
        // 2) Drain asynchronously
        Task.detached {
            for log in logs {
                
                let message = log.message
                
                for dispatcher in self.dispatchers {
                    guard dispatcher.dispatcherDelegate?.shouldDispatchMessage(message) ?? true,
                          dispatcher.dispatcherDelegate?.shouldDispatchMessageWithPriority(message.priority) ?? true
                    else { continue }
                    try? await dispatcher.handle(message)  //TODO: What happens is there is an exception?
                }
            }
        }
    }
}

