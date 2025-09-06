//
//  Untitled.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 11.02.25.
//

import Testing
import Foundation
@testable import SoftwareEtudesCoreMessageDispatching

@Suite("MessageDispatchingContext Tests")
struct MessageDispatchingContextTests {
    // MARK: - Helpers
    
    /// Loads the built-in JSON model file and returns a fully built context.
    private func makeContextFromModel() throws -> MessageDispatchingContext {
        guard let fileURL = Bundle.module.url(forResource: "model", withExtension: "json") else {
            fatalError("Missing model.json in bundle")
        }
        return try MessageDispatchingContext.dispatchingContextWith(url: fileURL)
    }
    
    // MARK: - Tests
    
    @Test
    func jsonLoadingInFramework_shouldSucceed() throws {
        let context = try makeContextFromModel()
        #expect(context.rootDispatcher() != nil)
    }
    
    @Test
    func buildDispatchers_createsCorrectHierarchy() throws {
        let context = try makeContextFromModel()
        guard let root = context.rootDispatcher() as? AbstractMessageDispatcher else {
            #expect(Bool(false), "Root dispatcher should be AbstractMessageDispatcher")
            return
        }
        #expect(root.name == "AnisMessenger")
        
        let formatter = root.nextDispatchers().first as? AbstractMessageDispatcher
        #expect(formatter?.name == "AnisFormatter")
        
        let interpreter = formatter?.nextDispatchers().first as? AbstractMessageDispatcher
        #expect(interpreter?.name == "AnisInterpreter")
        #expect(interpreter?.nextDispatchers().isEmpty == true)
    }
    
    @Test
    func emptyConfig_resultsInNoRoot() throws {
        let context = MessageDispatchingContext()
        let emptyConfig = DispatchersConfig(nodes: [])
        try context.buildDispatchers(from: emptyConfig)
        #expect(context.rootDispatcher() == nil)
    }
    
    @Test
    func missingChildReference_doesNotCreateUnknown() throws {
        let node = DispatcherNode(
            name: "Root", isRoot: true,
            className: nil, type: "any",
            nextDispatchers: ["NonExistent"],
            attributes: nil
        )
        let config = DispatchersConfig(nodes: [node])
        let context = MessageDispatchingContext()
        try context.buildDispatchers(from: config)
        let root = context.rootDispatcher()
        #expect(root?.nextDispatchers().isEmpty == true)
    }
    
    @Test
    func removalMethods_modifyChildList() throws {
        let nodes = [
            DispatcherNode(name: "Root", isRoot: true, className: nil, type: "any", nextDispatchers: ["Child1","Child2"], attributes: nil),
            DispatcherNode(name: "Child1", isRoot: false, className: nil, type: "any", nextDispatchers: nil, attributes: nil),
            DispatcherNode(name: "Child2", isRoot: false, className: nil, type: "any", nextDispatchers: nil, attributes: nil)
        ]
        let config = DispatchersConfig(nodes: nodes)
        let context = MessageDispatchingContext()
        try context.buildDispatchers(from: config)
        guard let root = context.rootDispatcher() as? AbstractMessageDispatcher else {
            #expect(Bool(false), "Root dispatcher missing")
            return
        }
        #expect(root.nextDispatchers().count == 2)
        
        // Remove one
        let firstChild = root.nextDispatchers()[0]
        root.removeFromNextDispatchers(firstChild)
        #expect(root.nextDispatchers().count == 1)
        
        // Clear all
        root.removeAllFromNextDispatchers()
        #expect(root.nextDispatchers().isEmpty)
    }
}
