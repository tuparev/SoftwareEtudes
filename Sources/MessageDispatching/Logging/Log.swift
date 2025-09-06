//
//  Log.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 30.10.24.
//

import Foundation
import Logging
import SoftwareEtudesCoreMessageDispatching

/// A thin wrapper around `Message` that carries a Swift-Log level
/// and knows how to dispatch itself to a given set of sinks.
public struct Log {
    public let message: Message
    public let priority: MessagePriority
    
    public enum MessageArgumentKeys: String, Codable {
        case metadata
        case source
        case file
        case function
        case line
    }
    
    /// Build a `Log` from a Swift-Log call, mapping levels → priorities.
    public static func make(level: Logging.Logger.Level,
                            message text: String,
                            metadata: Logging.Logger.Metadata? = nil,
                            source: String? = nil,
                            file: String? = nil,
                            function: String? = nil,
                            line: UInt? = nil,
                            dispatchers: [MessageDispatching] = []) -> Log {
        // 1) Map Swift-Log level to our MessagePriority
        let priority: MessagePriority = {
            switch level {
                case .trace, .debug:    return .debug
                case .info:             return .info
                case .notice, .warning: return .normal
                case .error:            return .high
                case .critical:         return .critical
                @unknown default:       return .normal
            }
        }()
        
        // 2) Decide payload (here we use the free-form key)
        let payload = MessagePayload.key(key: text)
        
        // 3) Build the arguments dictionary
        var arguments: [String:String] = [:]
        if let metadata = metadata,
           let data = try? JSONSerialization.data(withJSONObject: metadata.mapValues { "\($0)" }, options: []),
           let json = String(data: data, encoding: .utf8) {
            arguments[MessageArgumentKeys.metadata.rawValue] = json
        }
        if let source   = source { arguments[MessageArgumentKeys.source.rawValue] = source }
        if let file     = file { arguments[MessageArgumentKeys.file.rawValue] = file }
        if let function = function { arguments[MessageArgumentKeys.function.rawValue] = function }
        if let line     = line { arguments[MessageArgumentKeys.line.rawValue] = "\(line)" }
        
        // 4) Construct the Message
        let message = Message(
            payload: payload,
            priority: priority,
            arguments: arguments,
            actions: nil,
            formattingInfo: nil
        )
        
        return Log(message: message, priority: priority)
    }
    
    /// Primary initialiser.
    public init(message: Message, priority: MessagePriority) {
        self.message  = message
        self.priority = priority
    }
    
    /// Send this log’s message into the given dispatchers.
    public func dispatch(to dispatchers: [MessageDispatching]) async {
        for dispatcher in dispatchers {
            guard dispatcher.dispatcherDelegate?.shouldDispatchMessage(message) ?? true,
                  dispatcher.dispatcherDelegate?.shouldDispatchMessageWithPriority(message.priority) ?? true
            else { continue }
            try? await dispatcher.handle(message)
        }
    }
}
