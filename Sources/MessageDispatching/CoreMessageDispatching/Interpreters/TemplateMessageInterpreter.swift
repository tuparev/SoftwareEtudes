//
//  Untitled.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 10.07.25.
//

import Foundation

public final class TemplateMessageInterpreter: AbstractMessageInterpreter {
    public override func handle(_ message: Message) async throws {
        // 1) Mask/drop sensitive args
        try await super.handle(message)
        
        // 2) Format into a String
        let formatted = ""// lookup template + replace placeholders
        
        // 3) Create a new Message
        let formattedMsg = Message(payload: .key(key: formatted),
                                   priority: message.priority,
                                   arguments: nil,
                                   actions: message.actions,
                                   formattingInfo: message.formattingInfo)
        
        // 4) Hand *that* back to the dispatcher pipeline by printing it:
        //    (since interpreters by default just `print(cleaned)` if they have no args)
        print(formattedMsg)
        
        // **But do not** attempt to do your own fan-out—
        // the dispatcher that holds you as its `interpreter` will do it.
    }
}
