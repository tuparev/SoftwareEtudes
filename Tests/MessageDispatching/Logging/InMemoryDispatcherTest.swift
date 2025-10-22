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
        let message = Message(payload: .key(key: "test"), priority: .info)
        
        try? await dispatcher.handle(message)
        let logs = await dispatcher.getAllLogs()
        
        #expect(logs.count == 1)
        #expect(logs.first?.payload == message.payload)
    }
    
    @Test("Store multiple messages")
    func storeMultipleMessages() async {
        let dispatcher = InMemoryDispatcher()
        
        for i in 0..<10 {
            let message = Message(payload: .key(key: "message\(i)"), priority: .info)
            try? await dispatcher.handle(message)
        }
        
        let logs = await dispatcher.getAllLogs()
        #expect(logs.count == 10)
    }
}
