//
//  Messages.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 16.01.25.
//

import Testing
import Foundation
@testable import SoftwareEtudesCoreMessageDispatching

@Suite("Message Tests")
struct MessageTests {
    // MARK: - Test: Initialization
    @Test
    func messageInitialization_withAllValues_shouldSucceed() {
        let payload        = MessagePayload.key(key: "testKey")
        let arguments      = ["arg1": "value1", "arg2": "value2"]
        let actions        = ["action1": "email", "action2": "backup"]
        let formattingInfo = ["bold": "true", "color": "red"]
        
        let message = Message(
            payload: payload,
            priority: .normal,
            arguments: arguments,
            actions: actions,
            formattingInfo: formattingInfo
        )
        
        #expect(message.payload == payload)
        #expect(message.arguments?["arg1"] == "value1")
        #expect(message.actions?["action1"] == "email")
        #expect(message.formattingInfo?["bold"] == "true")
    }
    
    // MARK: - Test: Equatable
    @Test
    func messageEquality_whenPropertiesAreIdentical_shouldBeEqual() {
        let msg1 = Message(
            payload: .key(key: "sameKey"),
            priority: .low,
            arguments: ["a": "1"],
            actions: ["x": "y"],
            formattingInfo: ["f": "g"]
        )
        let msg2 = Message(
            payload: .key(key: "sameKey"),
            priority: .low,
            arguments: ["a": "1"],
            actions: ["x": "y"],
            formattingInfo: ["f": "g"]
        )
        #expect(msg1 == msg2)
    }
    
    // MARK: - Test: Payload Description
    @Test
    func payloadDescription_shouldReturnCorrectDescriptions() {
        let keyPayload  = MessagePayload.key(key: "k")
        let codePayload = MessagePayload.code(code: 42)
        
        #expect(keyPayload.description == "Key: k")
        #expect(codePayload.description == "Code: 42")
    }
    
    // MARK: - Test: Message Description
    @Test
    func messageDescription_shouldIncludeAllComponents() {
        let message = Message(
            payload: .key(key: "descKey"),
            priority: .high,
            arguments: ["arg": "val"],
            actions: ["act": "run"],
            formattingInfo: ["fmt": "yes"]
        )
        let desc = message.description
        #expect(desc.contains("Payload: Key: descKey"))
        #expect(desc.contains("Arguments: [\"arg\": \"val\"]"))
        #expect(desc.contains("Actions: [\"act\": \"run\"]"))
        #expect(desc.contains("FormattingInfo: [\"fmt\": \"yes\"]"))
    }
    
    // MARK: - Test: Codable
    @Test
    func messageEncodingDecoding_withAllValues_shouldSucceed() throws {
        let original = Message(
            payload: .code(code: 7),
            priority: .background,
            arguments: ["foo": "bar"],
            actions: ["do": "it"],
            formattingInfo: ["style": "bold"]
        )
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Message.self, from: data)
        #expect(decoded == original)
    }
    
    @Test
    func messageEncodingDecoding_withNilValues_shouldSucceed() throws {
        let original = Message(
            payload: .code(code: 99),
            priority: .info,
            arguments: nil,
            actions: nil,
            formattingInfo: nil
        )
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Message.self, from: data)
        #expect(decoded == original)
    }
}
