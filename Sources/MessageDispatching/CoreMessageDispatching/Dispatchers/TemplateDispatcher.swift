//
//  TemplateDispatcher.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 10.07.25.
//

import Foundation
/**
 [ RootDispatcher ]
 ↓
 [ TemplateDispatcher ]     ←–– handles JSON lookup + placeholder substitution
 ↓
 ┌───────┬────────┬────────────┬───────────────┐
 │ Console│  File  │   OSLog    │   Remote      │
 │Dispatcher│Dispatcher│Dispatcher│Dispatcher   │
 └───────┴────────┴────────────┴───────────────┘
 **/

/// A dispatcher that formats messages using JSON templates, then forwards them downstream.
public final class TemplateDispatcher: AbstractMessageDispatcher {
    private let environment: AbstractMessageInterpretingEnvironment
    private let dateFormatter = ISO8601DateFormatter() //$$$GT any feedback on this formatter?
    
    /// - Parameter environment: Provides coded/keyed templates and cleanup utilities.
    public init(environment: AbstractMessageInterpretingEnvironment) {
        self.environment = environment
        super.init(interpreter: nil, name: "TemplateFormatter")
    }
    
    /// Applies JSON‐based templates and placeholder substitution, then fans out.
    public override func handle(_ message: Message) async throws {
        // 1) Gather arguments
        let args = message.arguments ?? [:]
        
        // 2) Select the correct template
        let rawTemplate: String = {
            switch message.payload {
                case .code(let code):
                    return lookupCodedTemplate(code: code)
                case .key(let key):
                    return lookupKeyedTemplate(key: key)
            }
        }()
        
        // 3) Replace standard placeholders
        var formatted = rawTemplate
            .replacingOccurrences(of: "{timestamp}", with: dateFormatter.string(from: Date()))
            .replacingOccurrences(of: "{level}",     with: message.priority.description)
        
        // 4) Replace any {argName} placeholders
        for (k, v) in args {
            formatted = formatted.replacingOccurrences(of: "{\(k)}", with: v)
        }
        
        // 5) Wrap into a new Message with the formatted text
        let formattedMessage = Message(
            payload: .key(key: formatted),
            priority: message.priority,
            arguments: nil,
            actions: message.actions,
            formattingInfo: message.formattingInfo
        )
        
        // 6) Forward to next dispatchers
        try await super.handle(formattedMessage)
    }
    
    private func lookupCodedTemplate(code: Int) -> String {
        for template in environment.codedMessageTemplates where template.code == code {
            if let text = template.messageTemplates[environment.languagePreferences.first!] {
                return text
            }
        }
        return environment.defaultUnknownCodeMessage
    }
    
    private func lookupKeyedTemplate(key: String) -> String {
        for template in environment.keyedMessageTemplates where template.key == key {
            if let text = template.messageTemplates[environment.languagePreferences.first!] {
                return text
            }
        }
        return environment.defaultUnknownKeyMessage
    }
}
