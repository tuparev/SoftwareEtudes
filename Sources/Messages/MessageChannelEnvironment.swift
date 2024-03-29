//
//  MessageChannelEnvironment.swift
//  
//
//  Created by Georg Tuparev on 8.03.23.
//  Copyright © See Framework's LICENSE file
//

import Foundation

public class MessageChannelEnvironment {

    public var obfuscationCharacter              = "*"
    public var shouldObfuscateSensitiveArguments = true
    public var shouldChannelPrivateArguments     = false

    public var knownPublicArgumentKeys    = [String]()
    public var knownSensitiveArgumentKeys = [String]()
    public var knownPrivateArgumentKeys   = [String]()

    public var assumeUnknownArgumentKeysAs = MessagePrivacy.sensitive

    public init() {}
}
