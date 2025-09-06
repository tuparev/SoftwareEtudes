//
//  Untitled.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 30.04.25.
//

import Testing
import Foundation
@testable import SoftwareEtudesCoreMessageDispatching

// A simple test double for the environment
private struct TestEnv: MessageInterpretingEnvironmentProviding {
    var languagePreferences: [String] = []
    var ignoreMessagesWithoutTemplate: Bool = true
    var ignoreUnmatchedAttributes: Bool = true
    
    // unused
    func addCodedMessage(template: CodedMessageTemplate) {}
    func addKeyedMessage(template: KeyedMessageTemplate) {}
    func emptyCodedMessageTemplates() {}
    func emptyKeyedMessageTemplates() {}
    func codedMessageTemplatesFrom(jsonString: String) throws {}
    func keyedMessageTemplatesFrom(jsonString: String) throws {}
    
    // For cleanup: drop "?" or "!" prefixes
    func cleanedArgumentKey(_ key: String) -> String {
        if key.hasPrefix("?") { return String(key.dropFirst(1)) }
        if key.hasPrefix("!") { return String(key.dropFirst(1)) }
        return key
    }
    
    var sensitivityArgumentPrefix: String { "?" }
    var privateArgumentPrefix: String     { "!" }
}

@Suite("AbstractMessageInterpreter Tests")
struct AbstractMessageInterpreterTests {
    // MARK: - Test Double Environment
    private struct TestEnv: MessageInterpretingEnvironmentProviding {
        var languagePreferences: [String] = []
        var ignoreMessagesWithoutTemplate: Bool = true
        var ignoreUnmatchedAttributes: Bool = true
        func addCodedMessage(template: CodedMessageTemplate) {}
        func addKeyedMessage(template: KeyedMessageTemplate) {}
        func emptyCodedMessageTemplates() {}
        func emptyKeyedMessageTemplates() {}
        func codedMessageTemplatesFrom(jsonString: String) throws {}
        func keyedMessageTemplatesFrom(jsonString: String) throws {}
        func cleanedArgumentKey(_ key: String) -> String { key.trimmingCharacters(in: CharacterSet(charactersIn: "?!")) }
        var sensitivityArgumentPrefix: String { "?" }
        var privateArgumentPrefix: String     { "!" }
    }
    
    // MARK: - SUT Factory
    private var env = TestEnv()
    private var sut: AbstractMessageInterpreter { AbstractMessageInterpreter(environment: env) }
    
    @Test
    func defaults_areCorrect() {
        #expect(sut.obfuscationCharacter == "*")
        #expect(sut.shouldObfuscateSensitiveArguments)
    }
    
    @Test
    func handle_withNilArguments_doesNotThrow() async throws {
        let msg = Message(payload: .key(key: "k"), priority: .info, arguments: nil, actions: nil, formattingInfo: nil)
        try await sut.handle(msg)
        #expect(true)
    }
    
    @Test
    func handle_withEmptyArguments_doesNotThrow() async throws {
        let msg = Message(payload: .code(code: 1), priority: .debug, arguments: [:], actions: nil, formattingInfo: nil)
        try await sut.handle(msg)
        #expect(true)
    }
}
