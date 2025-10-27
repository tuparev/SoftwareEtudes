//
//  InMemoryDispatcherTest.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 22.10.25.
//

import Testing
@testable import SoftwareEtudesLogging
import SoftwareEtudesCoreMessageDispatching

// MARK: - Storage Tests

@Suite("InMemoryDispatcher Storage Tests")
struct InMemoryDispatcherStorageTests {
    
    @Test("Store single message")
    func storeSingleMessage() async {
        let dispatcher = InMemoryDispatcher()
        let message    = Message(payload: .key(key: "test"), priority: .info)
        
        try? await dispatcher.handle(message)
        let logs       = await dispatcher.getAllLogs()
        
        #expect(logs.count == 1)
        #expect(logs.first?.payload == message.payload)
    }
    
    @Test("Store multiple messages")
    func storeMultipleMessages() async {
        let dispatcher  = InMemoryDispatcher()
        
        for i in 0..<10 {
            let message = Message(payload: .key(key: "message\(i)"), priority: .info)
            try? await dispatcher.handle(message)
        }
        
        let logs        = await dispatcher.getAllLogs()
        #expect(logs.count == 10)
    }
}

// MARK: - Circular Buffer Tests
@Suite("InMemoryDispatcher Circular Buffer Tests")
struct InMemoryDispatcherCircularBufferTests {
    
    @Test("Removes oldest when full")
    func circularBufferRemovesOldestWhenFull() async {
        let dispatcher = InMemoryDispatcher(capacity: 3)
        
        for i in 0..<5 {
            let message = Message(payload: .key(key: "message\(i)"), priority: .info)
            try? await dispatcher.handle(message)
        }
        
        let logs = await dispatcher.getAllLogs()
        #expect(logs.count == 3)
        
        if case let .key(key: key2) = logs[0].payload {
            #expect(key2 == "message2")
        }
        if case let .key(key: key3) = logs[1].payload {
            #expect(key3 == "message3")
        }
        if case let .key(key: key4) = logs[2].payload {
            #expect(key4 == "message4")
        }
    }
    
    @Test("Continuous overwrite")
    func circularBufferContinuousOverwrite() async {
        let dispatcher                = InMemoryDispatcher(capacity: 2)
        
        let msg1                      = Message(payload: .code(code: 1), priority: .info)
        let msg2                      = Message(payload: .code(code: 2), priority: .info)
        try? await dispatcher.handle(msg1)
        try? await dispatcher.handle(msg2)
        
        var logs                      = await dispatcher.getAllLogs()
        #expect(logs.count == 2)
        
        let msg3                      = Message(payload: .code(code: 3), priority: .info)
        try? await dispatcher.handle(msg3)
        
        logs                          = await dispatcher.getAllLogs()
        #expect(logs.count == 2)
        if case let .code(code: code) = logs[0].payload {
            #expect(code == 2)
        }
        if case let .code(code: code) = logs[1].payload {
            #expect(code == 3)
        }
    }
}

// MARK: - Priority Filtering Tests
@Suite("InMemoryDispatcher Priority Filtering Tests")
struct InMemoryDispatcherPriorityFilteringTests {
    
    @Test("Filter by single priority")
    func filterLogsByPriority() async {
        let dispatcher = InMemoryDispatcher()
        
        try? await dispatcher.handle(Message(payload: .key(key: "info"), priority: .info))
        try? await dispatcher.handle(Message(payload: .key(key: "high"), priority: .high))
        try? await dispatcher.handle(Message(payload: .key(key: "high"), priority: .high))
        try? await dispatcher.handle(Message(payload: .key(key: "debug"), priority: .debug))
        try? await dispatcher.handle(Message(payload: .key(key: "critical"), priority: .critical))
        
        let highLogs = await dispatcher.filterLogs(by: .high)
        #expect(highLogs.count == 2)
    }
    
    @Test("Filter by multiple priorities")
    func filterLogsByMultiplePriorities() async {
        let dispatcher      = InMemoryDispatcher()
        
        try? await dispatcher.handle(Message(payload: .key(key: "info"), priority: .info))
        try? await dispatcher.handle(Message(payload: .key(key: "high"), priority: .high))
        try? await dispatcher.handle(Message(payload: .key(key: "debug"), priority: .debug))
        try? await dispatcher.handle(Message(payload: .key(key: "critical"), priority: .critical))
        
        let criticalAndHigh = await dispatcher.filterLogs(by: [.critical, .high])
        #expect(criticalAndHigh.count == 2)
    }
    
    @Test("Priority restriction during handle")
    func priorityRestrictionDuringHandle() async {
        let dispatcher = InMemoryDispatcher(priorities: [.high, .critical])
        
        try? await dispatcher.handle(Message(payload: .key(key: "info"), priority: .info))
        try? await dispatcher.handle(Message(payload: .key(key: "high"), priority: .high))
        try? await dispatcher.handle(Message(payload: .key(key: "debug"), priority: .debug))
        try? await dispatcher.handle(Message(payload: .key(key: "critical"), priority: .critical))
        
        let logs       = await dispatcher.getAllLogs()
        #expect(logs.count == 2)
    }
}
