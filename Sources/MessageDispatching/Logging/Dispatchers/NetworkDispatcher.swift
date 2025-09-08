//
//  NetworkDispatcher.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 16.01.25.
//

import Foundation
import SoftwareEtudesCoreMessageDispatching

/// A dispatcher that sends log messages over HTTP to a remote endpoint.
/// Supports batching, retry logic, and network connectivity monitoring.
public final class NetworkDispatcher: MessageDispatching {
    
    init(children: [MessageDispatching], dispatcherDelegate: (any SoftwareEtudesCoreMessageDispatching.MessageDispatchingDelegate)? = nil) {
        self.children = children
        self.dispatcherDelegate = dispatcherDelegate
    }
    
    // MARK: MessageDispatching
    public var dispatcherDelegate: (any SoftwareEtudesCoreMessageDispatching.MessageDispatchingDelegate)?
    
    
    public func nextDispatchers() -> [MessageDispatching] { return children }
    public func addToNextDispatchers(_ dispatcher: MessageDispatching) { children.append(dispatcher) }
    public func removeFromNextDispatchers(_ dispatcher:MessageDispatching) {
        children.removeAll { ($0 as AnyObject) === (dispatcher as AnyObject) }
    }
    public func removeAllFromNextDispatchers() { children.removeAll() }
    
    public func handle(_ message: SoftwareEtudesCoreMessageDispatching.Message) async throws {
        
    }
    
    // MARK: MessageDispatching
    private var children: [MessageDispatching]
  
}
