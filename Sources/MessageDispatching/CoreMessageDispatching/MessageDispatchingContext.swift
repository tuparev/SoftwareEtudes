//
//  MessageDispatchingContext.swift
//  SoftwareEtudes
//
//  Created by Georg Tuparev on 10/02/2025.
//

import Foundation

/// A single node in the dispatch graph, describing one dispatcher and its relationships.
///
/// - `name`: Unique identifier for the dispatcher.
/// - `isRoot`: Marks this node as the top-level entry point.
/// - `className`: Optional fully-qualified class name for custom creation.
/// - `type`: A string label categorising the dispatcher (e.g. "message_emitter").
/// - `nextDispatchers`: Names of child dispatchers to which messages should be forwarded.
/// - `attributes`: Arbitrary key/value metadata for dispatcher instantiation.
public struct DispatcherNode: Codable {
    let name: String
    let isRoot: Bool
    let className: String?
    let type: String
    let nextDispatchers: [String]?
    let attributes: [String: String]?
}

/// Root container for a set of `DispatcherNode` definitions.
///
/// Holds the array of dispatcher nodes
struct DispatchersConfig: Codable {
    let nodes: [DispatcherNode]
}

/// Factory protocol to allow custom creation of dispatcher instances.
///
/// Implementers may inspect the node's properties and return different
/// `MessageDispatching` concrete types as needed.
public protocol MessageDispatchingFactoryDelegate: AnyObject {
    func createDispatcher(for node: DispatcherNode) -> MessageDispatching?
}

/// Manages the lifecycle and wiring of a graph of message dispatchers based on JSON config. (for now JSON config)
open class MessageDispatchingContext {
    
    /// Optional delegate for custom dispatcher creation.
    public weak var delegate: MessageDispatchingFactoryDelegate?
    /// Map of dispatcher instances keyed by their node names.
    private var allDispatchers: [String: MessageDispatching] = [:]
    /// The root dispatcher, as marked by `isRoot` in configuration.
    private var root: MessageDispatching?
    
    /// Loads and builds a dispatcher graph from a JSON file URL.
    ///
    /// - Parameter url: File URL pointing to a JSON document matching `DispatchersConfig`.
    /// - Throws: Decoding or I/O errors if the file cannot be read or parsed.
    /// - Returns: A fully initialized `MessageDispatchingContext` with `root` set.
    public static func dispatchingContextWith(url: URL) throws -> MessageDispatchingContext! {
        let context = MessageDispatchingContext()
        try context.loadModelJsonFrom(url: url)
        return context
    }

    // Retrieves the configured root dispatcher, or `nil` if none was flagged.
    public func rootDispatcher() -> MessageDispatching! { return self.root }
    
    /// Reads the JSON file at `url`, decodes to `DispatchersConfig`, and builds the dispatcher graph.
    ///
    /// - Parameter url: URL of the JSON configuration file.
    /// - Throws: Errors from file I/O or JSON decoding.
    private func loadModelJsonFrom(url: URL) throws {
        let fileURL = URL(fileURLWithPath: url.path())
        let data    = try Data(contentsOf: fileURL)
        let config  = try JSONDecoder().decode(DispatchersConfig.self, from: data)
        try buildDispatchers(from: config)
        print("Parsed JSON dictionary:", config)
    }
    
    /// Creates and links dispatcher instances according to `DispatchersConfig`.
    ///
    /// - Parameter config: Parsed configuration containing nodes and relationships.
    /// - Throws: No errors by default, but implementers may throw if needed.
    func buildDispatchers(from config: DispatchersConfig) throws {
        // Create a dispatcher object for each node
        for node in config.nodes {
            let dispatcher: MessageDispatching
            if let custom = delegate?.createDispatcher(for: node) {
                dispatcher = custom
            } else {
                // FALLBACK: build a plain AbstractMessageDispatcher for any node
                dispatcher = AbstractMessageDispatcher(interpreter: nil, name: node.name)
            }
            allDispatchers[node.name] = dispatcher
        }
        
        // Wire up the graph
        for node in config.nodes {
            guard let current = allDispatchers[node.name] else { continue }
            if let children = node.nextDispatchers {
                for childName in children {
                    if let child = allDispatchers[childName] {
                        current.addToNextDispatchers(child)
                    } else {
                        print("No dispatcher found with name \(childName)")
                    }
                }
            }
        }
        
        // Identify the root
        if let rootNode = config.nodes.first(where: { $0.isRoot }) {
            root = allDispatchers[rootNode.name]
        }
    }
}
