//
//  DefaultMessageArgumentSensitivityProvider.swift
//  SoftwareEtudes
//
//  Created by Ani Klekchyan Work on 21.03.25.
//

import Testing
@testable import SoftwareEtudesCoreMessageDispatching

struct DefaultMessageArgumentSensitivityProviderTests {
    
    var sut = DefaultMessageArgumentSensitivityProvider()
    
    // MARK: - Tests for isSensitiveArgument(_:)
    
    @Test
    func isSensitiveArgument_whenKeyPrefixedWithQuestionMark_returnsTrue() {
        #expect(sut.isSensitiveArgument("?someKey"))
    }
    
    @Test
    func isSensitiveArgument_whenKeyPrefixedWithExclamationMark_returnsFalse() {
        #expect(!sut.isSensitiveArgument("!someKey"))
    }
    
    @Test
    func isSensitiveArgument_whenKeyHasNoPrefix_returnsFalse() {
        #expect(!sut.isSensitiveArgument("plainKey"))
    }
    
    // MARK: - Tests for isPrivateArgument(_:)
    
    @Test
    func isPrivateArgument_whenKeyPrefixedWithExclamationMark_returnsTrue() {
        #expect(sut.isPrivateArgument("!someKey"))
    }
    
    @Test
    func isPrivateArgument_whenKeyPrefixedWithQuestionMark_returnsFalse() {
        #expect(!sut.isPrivateArgument("?someKey"))
    }
    
    @Test
    func isPrivateArgument_whenKeyHasNoPrefix_returnsFalse() {
        #expect(!sut.isPrivateArgument("plainKey"))
    }
    
    // MARK: - Tests for makeSensitive(arguments:sensitiveKeys:)
    
    @Test
    func makeSensitive_withNilArguments_returnsNil() {
        let result = sut.makeSensitive(arguments: nil, sensitiveKeys: ["userToken"])
        #expect(result == nil)
    }
    
    @Test
    func makeSensitive_whenNoSensitiveKeysGiven_returnsSameDictionary() {
        let original: [String: String] = ["one": "1", "two": "2"]
        let result = sut.makeSensitive(arguments: original, sensitiveKeys: [])
        #expect(result == original)
    }
    
    @Test
    func makeSensitive_whenKeyIsInSensitiveKeys_prefixesKeyWithQuestionMark() {
        let original = ["token": "ABC123", "other": "value"]
        let result = sut.makeSensitive(arguments: original, sensitiveKeys: ["token"])
        #expect(result?["?token"] == "ABC123")
        #expect(result?["token"] == nil)
        #expect(result?["other"] == "value")
    }
    
    @Test
    func makeSensitive_whenKeyIsAlreadyPrefixed_doesNotChangeIt() {
        let original = ["?alreadySensitive": "secret", "!alreadyPrivate": "privateValue"]
        let result = sut.makeSensitive(arguments: original, sensitiveKeys: ["?alreadySensitive", "!alreadyPrivate"])
        #expect(result == original)
    }
    
    @Test
    func makeSensitive_multipleKeys_somePrefixed_someNot() {
        let original = [
            "token": "ABC123",
            "?user": "someone",
            "!card": "4111-1111-1111-1111"
        ]
        let keysToMakeSensitive = ["token", "?user", "!card"]
        let result = sut.makeSensitive(arguments: original, sensitiveKeys: keysToMakeSensitive)
        
        #expect(result?["?token"] == "ABC123")
        #expect(result?["?user"] == "someone")
        #expect(result?["!card"] == "4111-1111-1111-1111")
        #expect(result?["token"] == nil)
        #expect(result?.count == 3)
    }
    
    // MARK: - Tests for makePrivate(arguments:sensitiveKeys:)
    
    @Test
    func makePrivate_withNilArguments_returnsNil() {
        let result = sut.makePrivate(arguments: nil, privateKeys: ["ccNumber"])
        #expect(result == nil)
    }
    
    @Test
    func makePrivate_whenNoPrivateKeysGiven_returnsSameDictionary() {
        let original: [String: String] = ["one": "1", "two": "2"]
        let result = sut.makePrivate(arguments: original, privateKeys: [])
        #expect(result == original)
    }
    
    @Test
    func makePrivate_whenKeyIsInPrivateKeys_prefixesKeyWithExclamationMark() {
        let original = ["creditCard": "4111-1111-1111-1111", "other": "value"]
        let result = sut.makePrivate(arguments: original, privateKeys: ["creditCard"])
        #expect(result?["!creditCard"] == "4111-1111-1111-1111")
        #expect(result?["creditCard"] == nil)
        #expect(result?["other"] == "value")
    }
    
    @Test
    func makePrivate_whenKeyIsAlreadyPrefixed_doesNotChangeIt() {
        let original = ["!alreadyPrivate": "secretCard", "?alreadySensitive": "secret"]
        let result = sut.makePrivate(arguments: original, privateKeys: ["!alreadyPrivate", "?alreadySensitive"])
        #expect(result == original)
    }
    
    @Test
    func makePrivate_multipleKeys_somePrefixed_someNot() {
        let original = [
            "cc": "4111-1111-1111-1111",
            "?user": "someone",
            "!token": "ABC123"
        ]
        let keysToMakePrivate = ["cc", "?user", "!token"]
        let result = sut.makePrivate(arguments: original, privateKeys: keysToMakePrivate)
        
        #expect(result?["!cc"] == "4111-1111-1111-1111")
        #expect(result?["?user"] == "someone")
        #expect(result?["!token"] == "ABC123")
        #expect(result?["cc"] == nil)
        #expect(result?.count == 3)
    }
}

///$$$GT testing with Suits. I need your opinion.

@Suite("DefaultMessageArgumentSensitivityProvider Tests")
struct DefaultMessageArgumentSensitivityProviderTestsWithSuits {
    
    // MARK: - Suite: isSensitiveArgument
    
    @Suite struct IsSensitiveArgument {
        let sut = DefaultMessageArgumentSensitivityProvider()
        
        @Test
        func whenKeyPrefixedWithQuestionMark_returnsTrue() {
            #expect(sut.isSensitiveArgument("?someKey"))
        }
        
        @Test
        func whenKeyPrefixedWithExclamationMark_returnsFalse() {
            #expect(!sut.isSensitiveArgument("!someKey"))
        }
        
        @Test
        func whenKeyHasNoPrefix_returnsFalse() {
            #expect(!sut.isSensitiveArgument("plainKey"))
        }
    }
    
    // MARK: - Suite: isPrivateArgument
    
    @Suite struct IsPrivateArgument {
        let sut = DefaultMessageArgumentSensitivityProvider()
        
        @Test
        func whenKeyPrefixedWithExclamationMark_returnsTrue() {
            #expect(sut.isPrivateArgument("!someKey"))
        }
        
        @Test
        func whenKeyPrefixedWithQuestionMark_returnsFalse() {
            #expect(!sut.isPrivateArgument("?someKey"))
        }
        
        @Test
        func whenKeyHasNoPrefix_returnsFalse() {
            #expect(!sut.isPrivateArgument("plainKey"))
        }
    }
    
    // MARK: - Suite: makeSensitive
    
    @Suite struct MakeSensitive {
        let sut = DefaultMessageArgumentSensitivityProvider()
        
        @Test
        func withNilArguments_returnsNil() {
            let result = sut.makeSensitive(arguments: nil, sensitiveKeys: ["userToken"])
            #expect(result == nil)
        }
        
        @Test
        func whenNoSensitiveKeysGiven_returnsSameDictionary() {
            let original: [String: String] = ["one": "1", "two": "2"]
            let result = sut.makeSensitive(arguments: original, sensitiveKeys: [])
            #expect(result == original)
        }
        
        @Test
        func whenKeyIsInSensitiveKeys_prefixesKeyWithQuestionMark() {
            let original = ["token": "ABC123", "other": "value"]
            let result = sut.makeSensitive(arguments: original, sensitiveKeys: ["token"])
            #expect(result?["?token"] == "ABC123")
            #expect(result?["token"] == nil)
            #expect(result?["other"] == "value")
        }
        
        @Test
        func whenKeyIsAlreadyPrefixed_doesNotChangeIt() {
            let original = ["?alreadySensitive": "secret", "!alreadyPrivate": "privateValue"]
            let result = sut.makeSensitive(arguments: original,
                                           sensitiveKeys: ["?alreadySensitive", "!alreadyPrivate"])
            #expect(result == original)
        }
        
        @Test
        func multipleKeys_somePrefixed_someNot() {
            let original = [
                "token": "ABC123",
                "?user": "someone",
                "!card": "4111-1111-1111-1111"
            ]
            let keysToMakeSensitive = ["token", "?user", "!card"]
            let result = sut.makeSensitive(arguments: original, sensitiveKeys: keysToMakeSensitive)
            
            #expect(result?["?token"] == "ABC123")
            #expect(result?["?user"] == "someone")
            #expect(result?["!card"] == "4111-1111-1111-1111")
            #expect(result?["token"] == nil)
            #expect(result?.count == 3)
        }
    }
    
    // MARK: - Suite: makePrivate
    
    @Suite struct MakePrivate {
        let sut = DefaultMessageArgumentSensitivityProvider()
        
        @Test
        func withNilArguments_returnsNil() {
            let result = sut.makePrivate(arguments: nil, privateKeys: ["ccNumber"])
            #expect(result == nil)
        }
        
        @Test
        func whenNoPrivateKeysGiven_returnsSameDictionary() {
            let original: [String: String] = ["one": "1", "two": "2"]
            let result = sut.makePrivate(arguments: original, privateKeys: [])
            #expect(result == original)
        }
        
        @Test
        func whenKeyIsInPrivateKeys_prefixesKeyWithExclamationMark() {
            let original = ["creditCard": "4111-1111-1111-1111", "other": "value"]
            let result = sut.makePrivate(arguments: original, privateKeys: ["creditCard"])
            #expect(result?["!creditCard"] == "4111-1111-1111-1111")
            #expect(result?["creditCard"] == nil)
            #expect(result?["other"] == "value")
        }
        
        @Test
        func whenKeyIsAlreadyPrefixed_doesNotChangeIt() {
            let original = ["!alreadyPrivate": "secretCard", "?alreadySensitive": "secret"]
            let result = sut.makePrivate(arguments: original,
                                         privateKeys: ["!alreadyPrivate", "?alreadySensitive"])
            #expect(result == original)
        }
        
        @Test
        func multipleKeys_somePrefixed_someNot() {
            let original = [
                "cc": "4111-1111-1111-1111",
                "?user": "someone",
                "!token": "ABC123"
            ]
            let keysToMakePrivate = ["cc", "?user", "!token"]
            let result = sut.makePrivate(arguments: original, privateKeys: keysToMakePrivate)
            
            #expect(result?["!cc"] == "4111-1111-1111-1111")
            #expect(result?["?user"] == "someone")
            #expect(result?["!token"] == "ABC123")
            #expect(result?["cc"] == nil)
            #expect(result?.count == 3)
        }
    }
}
