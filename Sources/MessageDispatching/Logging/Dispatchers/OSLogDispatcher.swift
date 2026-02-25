//
//  OSLogDispatcher.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 26.06.25.
//

import Foundation
import os
import SoftwareEtudesCoreMessageDispatching

public final class OSLogDispatcher: MessageDispatching {
    private let messageDispatcher: AbstractMessageDispatcher
    private let logHandle: OSLog
    private let includeDetailedInfo: Bool
    
    public var dispatcherDelegate: MessageDispatchingDelegate? {
        get { messageDispatcher.dispatcherDelegate }
        set { messageDispatcher.dispatcherDelegate = newValue }
    }
    
    /// Initialise OSLogDispatcher with performance options
    /// - Parameters:
    ///   - subsystem: OSLog subsystem identifier
    ///   - category: OSLog category
    ///   - interpreter: Optional message interpreter
    ///   - includeDetailedInfo: Whether to include arguments, actions, and formatting info in logs (default: true)
    ///                         Set to false for better performance when detailed info is not needed
    public init(subsystem: String = Bundle.main.bundleIdentifier ?? "com.TT.app", category: String = "Messaging",
                interpreter: MessageInterpreting? = nil, includeDetailedInfo: Bool = true) {
        self.logHandle           = OSLog(subsystem: subsystem, category: category)
        self.messageDispatcher   = AbstractMessageDispatcher(interpreter: interpreter, name: category)
        self.includeDetailedInfo = includeDetailedInfo
    }
    
    public func nextDispatchers() -> [MessageDispatching]                    { messageDispatcher.nextDispatchers() } //TODO: Is it not better to have a singular name?
    public func addToNextDispatchers(_ dispatching: MessageDispatching)      { messageDispatcher.addToNextDispatchers(dispatching) }
    public func removeFromNextDispatchers(_ dispatching: MessageDispatching) { messageDispatcher.removeFromNextDispatchers(dispatching) }
    public func removeAllFromNextDispatchers()                               { messageDispatcher.removeAllFromNextDispatchers() }

    public func handle(_ message: Message) async throws {
        let level = osLogType(for: message.priority)
        
        // Performance optimisation: Only convert to strings if logging is enabled for this level
        if logHandle.isEnabled(type: level) {
            let body: String = {
                switch message.payload {
                case .key(let key):   return key
                case .code(let code): return "\(code)"
                }
            }()

            if includeDetailedInfo, let arguments = message.arguments, !arguments.isEmpty {
                os_log("%{public}@ | %{public}@", log: logHandle, type: level, body, arguments.description)
            } else {
                os_log("%{public}@", log: logHandle, type: level, body)
            }
        }
        
        // Handle downstream processing with proper error context
        do { try await messageDispatcher.handle(message) }
        catch {
            // Log the downstream error but don't let it prevent OSLog from working
            // Always log errors regardless of level filtering
            os_log(
                "OSLogDispatcher: Failed to process message downstream - %{public}@",
                log: logHandle, type: .error, String(describing: error)
            )
            throw error
        }
    }
    
    /// Performance optimization: Pre-computed mapping table for priority -> OSLogType conversion
    private static let priorityToOSLogTypeMap: [MessagePriority: OSLogType] = [
        .debug:      .debug,
        .info:       .info,
        .background: .info,
        .normal:     .default,
        .low:        .default,
        .high:       .error,
        .critical:   .fault
    ]
    
    private func osLogType(for priority: MessagePriority) -> OSLogType { Self.priorityToOSLogTypeMap[priority] ?? .default }
}
