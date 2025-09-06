//
//  MessageInterpretingEnvironment.swift
//  
//
//  Created by Georg Tuparev on 9.11.22.
//  Copyright © See Framework's LICENSE file
//

import Foundation
import SoftwareEtudesUtilities

// A possible common use:
// There are config files (JSON) for keys and codes in different languages. Perhaps they can contain also default settings
// for undefined keys and codes (not defined by the protocol yet)!
// So, the Interpreter will ask the Environment to load the default settings (or configure them from source code (or
// both) and then the environment will be used to implement the handle(_ message:) method.
// Things to consider:
// - Setting a folder for config files and auto-loading of config files
// - Default (language aware) file name, e.g. keys_en.json
// - What happens if neither default or chosen config file exist (do we need standardised error handling?)
// - Should we implement here also ArgumentSensitivity? It is less elegant, but perhaps much faster. Do we care?
// - What happens if there is a private argument? The protocol does not define this!



/// A template mapping an integer code to its localized message strings.
public struct CodedMessageTemplate: Sendable, Codable {
    /// The numeric code identifying this template.
    public let code: Int
    /// A dictionary of language code → message text.
    public let messageTemplates: [String : String]
}

/// A template mapping a string key to its localized message strings.
public struct KeyedMessageTemplate: Sendable, Codable {
    /// The lookup key for this template.
    public let key: String
    /// A dictionary of language code → message text.
    public let messageTemplates: [String : String]
}

/// Provides all configuration, template‐loading, and argument‐cleanup utilities
/// needed by a `MessageInterpreting` instance.
public protocol MessageInterpretingEnvironmentProviding {

    /// Preferred languages in descending order of priority (e.g. `["en","fr"]`).
    var languagePreferences: [String]       { get set }
    /// If `false`, missing‐template scenarios will throw rather than skip.
    var ignoreMessagesWithoutTemplate: Bool { get set }
    /// If `false`, unmatched message attributes will throw rather than skip.
    var ignoreUnmatchedAttributes: Bool     { get set }

    /// Adds a coded template to the environment.
    func addCodedMessage(template: CodedMessageTemplate)
    /// Adds a keyed template to the environment.
    func addKeyedMessage(template: KeyedMessageTemplate)
    /// Removes all coded templates.
    func emptyCodedMessageTemplates()
    /// Removes all keyed templates.
    func emptyKeyedMessageTemplates()

    /// Loads coded templates from a JSON string.
    ///
    /// - Parameter jsonString: JSON representing `[CodedMessageTemplate]`.
    /// - Throws: A decoding error if parsing fails.
    func codedMessageTemplatesFrom(jsonString: String) throws
    
    /// Loads keyed templates from a JSON string.
    ///
    /// - Parameter jsonString: JSON representing `[KeyedMessageTemplate]`.
    /// - Throws: A decoding error if parsing fails.
    func keyedMessageTemplatesFrom(jsonString: String) throws
    
    /// Strips any leading sensitivity (`?`) or privacy (`!`) prefix from a raw key.
    ///
    /// - Parameter key: The original key, possibly prefixed.
    /// - Returns: The cleaned key without any prefix.
    func cleanedArgumentKey(_ key: String) -> String
    
    // MARK: – Argument-Sensitivity Configuration
    
    /// Prefix used to mark arguments as sensitive (e.g. `?token`).
    var sensitivityArgumentPrefix: String { get }
    /// Prefix used to mark arguments as private (e.g. `!password`).
    var privateArgumentPrefix: String { get }
}

/// Default, file-backed environment that implements
/// `MessageInterpretingEnvironmentProviding
open class AbstractMessageInterpretingEnvironment : MessageInterpretingEnvironmentProviding {

    //MARK: Reasonable defaults
    
    /// Default language code when none is specified.
    public static var defaultLanguageCode               = "en"
    /// Default numeric code representing "unknown".
    public static var defaultUnknownCode                = Int.max
    /// Default key representing "unknown".
    public static var defaultUnknownKey                 = "<unknown>"
    /// Default message when no template is found.
    public static var defaultMassageWithoutTemplate     = "Message without templates"
    /// Default message when unmatched attributes are found.
    public static var defaultUnmatchedAttributesMessage = "Unmatched attributes found"

    /// Represents errors that may occur when loading message templates from JSON files.
    public enum TemplateLoadingError: Error, CustomStringConvertible {
        /// Thrown if a file was not found at the expected URL.
        case fileNotFound(url: URL)

        /// Thrown if reading or decoding the JSON file fails.
        case couldNotParseTemplate(url: URL, underlying: Error)

        /// Thrown if no files were found for any of the preferred languages, and
        /// `ignoreMessagesWithoutTemplate` is `false`.
        case noTemplatesFoundForPreferredLanguages([String])

        /// Thrown if the configuration folder is not set.
        case configurationFolderNotSet

        public var description: String {
            switch self {
                case .fileNotFound(let url):
                    return "Template file not found at path: \(url.path)"
                case .couldNotParseTemplate(let url, let underlying):
                    return "Failed to parse template file at \(url.path). Underlying error: \(underlying)"
                case .noTemplatesFoundForPreferredLanguages(let languages):
                    return "No template files were located for any of the preferred languages: \(languages)"
                case .configurationFolderNotSet:
                    return "Configuration folder is not set."
            }
        }
    }

    /// Represents optional fallback messages loaded from `defaults.json`.
    public struct DefaultTemplateSettings: Codable, Sendable {
        /// Fallback for unknown keys.
        public let unknownKeyMessage: String?
        /// Fallback for unknown codes.
        public let unknownCodeMessage: String?
    }

    // MARK: MessageInterpretingEnvironmentProviding

    public var languagePreferences: [String]

    public private(set) var codedMessageTemplates = [CodedMessageTemplate]()
    public private(set) var keyedMessageTemplates = [KeyedMessageTemplate]()
    
    public var ignoreMessagesWithoutTemplate = true
    public var ignoreUnmatchedAttributes     = true

    /// If `true`, missing files will throw rather than be skipped.
    public var throwOnMissingFiles: Bool = false
    /// If `true`, parsing errors will throw rather than be skipped.
    public var throwOnParsingError: Bool = false
    
    /// Message used when a key is not found.
    public var defaultUnknownKeyMessage: String = "<unknown key>"
    /// Message used when a code is not found.
    public var defaultUnknownCodeMessage: String = "Unknown code"
    
    // MARK: Template Methods
    /// Adds a coded template.
    public func addCodedMessage(template: CodedMessageTemplate) { codedMessageTemplates.append(template) }
    /// Adds a keyed template.
    public func addKeyedMessage(template: KeyedMessageTemplate) { keyedMessageTemplates.append(template) }
    /// Removes all coded templates.
    public func emptyCodedMessageTemplates() { codedMessageTemplates.removeAll() }
    /// Removes all keyed templates.
    public func emptyKeyedMessageTemplates() { keyedMessageTemplates.removeAll() }
    /// Loads keyed templates from JSON.
    public func keyedMessageTemplatesFrom(jsonString: String) throws {
        keyedMessageTemplates = try jsonDecoder.decode([KeyedMessageTemplate].self, from: Data(jsonString.utf8))
    }
    /// Loads coded templates from JSON.
    public func codedMessageTemplatesFrom(jsonString: String) throws {
        codedMessageTemplates = try jsonDecoder.decode([CodedMessageTemplate].self, from: Data(jsonString.utf8))
    }
    
    // MARK: Argument-Sensitivity Configuration
    public var sensitivityArgumentPrefix: String { DefaultMessageArgumentSensitivityProvider().sensitivityArgumentPrefix }
    public var privateArgumentPrefix:     String { DefaultMessageArgumentSensitivityProvider().privateArgumentPrefix }
    
    /// Folder where JSON configuration files live.
    public var configFolder: URL? {
        get { return _configFolder }
        set { _configFolder = newValue }
    }
    
    /// The default language code to use as a fallback when a specific language file is not found.
    #warning("This is wrong! There is no way to set the var. And why don't use defaultLanguageCode?")
    // Using defaultLanguageCode as fallback value.
    public var defaultLanguageCodeForFallback: String {
        return AbstractMessageInterpretingEnvironment.defaultLanguageCode
    }

    // MARK: Initialisation
    
    /// Creates an empty environment with the given language preferences.
    ///
    /// - Parameter languagePreferences: Preferred languages in order.
    public init(languagePreferences: [String] = [AbstractMessageInterpretingEnvironment.defaultLanguageCode]) {
        self.languagePreferences = languagePreferences
    }
    
    /// Strips any `?` or `!` prefix from an argument key.
    ///
    /// - Parameter key: Raw key.
    /// - Returns: Key without prefix.
    public func cleanedArgumentKey(_ key: String) -> String {
        if key.hasPrefix(privateArgumentPrefix) {
            return String(key.dropFirst(privateArgumentPrefix.count))
        }
        if key.hasPrefix(sensitivityArgumentPrefix) {
            return String(key.dropFirst(sensitivityArgumentPrefix.count))
        }
        return key
    }
    
    //MARK: - Private functionality
    private let jsonDecoder = PrettyJSONDecoder()
    private var _configFolder: URL?
}

public extension AbstractMessageInterpretingEnvironment {
    
    // MARK: Public Methods
    
    /// Loads all `codes_{lang}.json` and `keys_{lang}.json` for each preferred language.
    ///
    /// - Parameter folder: Directory containing template files.
    /// - Returns: Filenames successfully loaded.
    /// - Throws: `TemplateLoadingError` if missing or malformed and flags require errors.
    func loadAllTemplates(from folder: URL) throws -> [String] {
        var loadedFiles = [String]()
        
        for language in languagePreferences {
            // Attempt codes_{lang}.json
            let codedFile   = "codes_\(language).json"
            let codedURL    = folder.appendingPathComponent(codedFile)
            let codedLoaded = try loadCodedTemplatesIfPresent(at: codedURL)

            if codedLoaded { loadedFiles.append(codedFile) }
            
            // Attempt keys_{lang}.json
            let keyedFile   = "keys_\(language).json"
            let keyedURL    = folder.appendingPathComponent(keyedFile)
            let keyedLoaded = try loadKeyedTemplatesIfPresent(at: keyedURL)

            if keyedLoaded { loadedFiles.append(keyedFile) }
        }
        
        // If no templates found at all, check if we should throw.
        if loadedFiles.isEmpty && !ignoreMessagesWithoutTemplate {
            throw TemplateLoadingError.noTemplatesFoundForPreferredLanguages(languagePreferences)
        }
        
        return loadedFiles
    }
    
    /// Auto-loads coded/keyed JSON templates and optional `defaults.json` from `configFolder`.
    ///
    /// - Throws:
    ///   - `TemplateLoadingError.configurationFolderNotSet` if `configFolder` is `nil`.
    ///   - Other `TemplateLoadingError` if files are missing or malformed and flags require errors.
    func autoLoadTemplates() throws {
        // Check that the configuration folder is set.
        guard let folder = self.configFolder else {
            throw TemplateLoadingError.configurationFolderNotSet
        }
        
        // Create a mutable copy of language preferences and add the fallback language if needed.
        var languages = languagePreferences
        if !languages.contains(defaultLanguageCodeForFallback) {
            languages.append(defaultLanguageCodeForFallback)
        }
        
        var loadedFiles = [String]()
        
        // Iterate over each language preference and attempt to load templates.
        for lang in languages {
            let codesFile = "codes_\(lang).json"
            let keysFile = "keys_\(lang).json"
            let codesURL = folder.appendingPathComponent(codesFile)
            let keysURL = folder.appendingPathComponent(keysFile)
            
            do {
                let codedLoaded = try loadCodedTemplatesIfPresent(at: codesURL)
                let keyedLoaded = try loadKeyedTemplatesIfPresent(at: keysURL)
                if codedLoaded || keyedLoaded {
                    // Append only the filenames of files that exist.
                    let filesForLang = [codesFile, keysFile].filter {
                        FileManager.default.fileExists(atPath: folder.appendingPathComponent($0).path)
                    }
                    loadedFiles.append(contentsOf: filesForLang)
                }
            } catch {
                // Optionally log the error and continue to the next language.
                // For now, we simply continue.
            }
        }
        
        if loadedFiles.isEmpty && !ignoreMessagesWithoutTemplate {
            throw TemplateLoadingError.noTemplatesFoundForPreferredLanguages(languagePreferences)
        }
        
        // Attempt to load default settings from defaults.json
        let defaultsURL = folder.appendingPathComponent("defaults.json")
        if FileManager.default.fileExists(atPath: defaultsURL.path) {
            let data = try Data(contentsOf: defaultsURL)
            let defaultsSettings = try jsonDecoder.decode(DefaultTemplateSettings.self, from: data)
            if let unknownKeyMsg = defaultsSettings.unknownKeyMessage {
                self.defaultUnknownKeyMessage = unknownKeyMsg
            }
            if let unknownCodeMsg = defaultsSettings.unknownCodeMessage {
                self.defaultUnknownCodeMessage = unknownCodeMsg
            }
        }
    }
    
    // MARK: - Internal Helpers
    
    /// Loads and decodes a JSON template file if present, appending results via `appender`.
    ///
    /// - Parameters:
    ///   - url: URL of the JSON file.
    ///   - decodeType: Array type to decode.
    ///   - appender: Closure to append decoded templates.
    /// - Returns: `true` if file existed and decoded; otherwise `false`.
    /// - Throws:
    ///   - `TemplateLoadingError.fileNotFound` if missing and `throwOnMissingFiles == true`.
    ///   - `TemplateLoadingError.couldNotParseTemplate` if malformed and `throwOnParsingError == true`.
    private func loadTemplatesIfPresent<TemplateType: Decodable>(
        at url: URL,
        decodeType: [TemplateType].Type,
        appender: ([TemplateType]) -> Void
    ) throws -> Bool {
        // 1) Ensure file exists or decide whether to throw/skip
        guard try ensureFileExists(at: url) else {
            return false // No file, and we didn't throw => skip
        }
        
        // 2) Attempt decoding
        do {
            let data             = try Data(contentsOf: url)
            let decodedTemplates = try jsonDecoder.decode(decodeType, from: data)

            // 3) Append to whichever array or storage the caller specifies
            appender(decodedTemplates)
            return true
        }
        catch {
            #if DEBUG
            assertionFailure("Parsing failed for file at \(url.path); skipping file. Error: \(error)")
            #endif
            if throwOnParsingError {
                throw TemplateLoadingError.couldNotParseTemplate(url: url, underlying: error)
            }
            return false
        }
    }
    
    /// Convenience wrapper to load coded message templates.
    ///
    /// - Parameter url: URL of the `codes_{lang}.json` file.
    /// - Returns: `true` if loaded; otherwise `false`.
    private func loadCodedTemplatesIfPresent(at url: URL) throws -> Bool {
        try loadTemplatesIfPresent(at: url, decodeType: [CodedMessageTemplate].self) { decoded in
            // Append them into codedMessageTemplates
            codedMessageTemplates.append(contentsOf: decoded)
        }
    }

    /// Convenience wrapper to load keyed message templates.
    ///
    /// - Parameter url: URL of the `keys_{lang}.json` file.
    /// - Returns: `true` if loaded; otherwise `false`.
    private func loadKeyedTemplatesIfPresent(at url: URL) throws -> Bool {
        try loadTemplatesIfPresent(at: url, decodeType: [KeyedMessageTemplate].self) { decoded in
            // Append them into keyedMessageTemplates
            keyedMessageTemplates.append(contentsOf: decoded)
        }
    }
    
    /// Loads `codes_{lang}.json` and `keys_{lang}.json` only for `languagePreferences`.
    ///
    /// - Parameter folder: Directory containing template files.
    /// - Returns: Filenames successfully loaded.
    /// - Throws: `TemplateLoadingError.noTemplatesFoundForPreferredLanguages` if none found and flags require.
    func loadTemplatesForPreferredLanguages(from folder: URL) throws -> [String] {
        var loadedFiles = [String]()
        for lang in languagePreferences {
            let codesFile = "codes_\(lang).json"
            let keysFile  = "keys_\(lang).json"
            let codesURL  = folder.appendingPathComponent(codesFile)
            let keysURL   = folder.appendingPathComponent(keysFile)
            
            let codedLoaded = try loadCodedTemplatesIfPresent(at: codesURL)
            let keyedLoaded = try loadKeyedTemplatesIfPresent(at: keysURL)
            if codedLoaded || keyedLoaded {
                loadedFiles.append(contentsOf: [codesFile, keysFile].filter { FileManager.default.fileExists(atPath: folder.appendingPathComponent($0).path) })
            }
        }
        
        if loadedFiles.isEmpty && !ignoreMessagesWithoutTemplate {
            throw TemplateLoadingError.noTemplatesFoundForPreferredLanguages(languagePreferences)
        }
        
        return loadedFiles
    }
    
    
    // MARK: - Private Helpers
    
    /// Checks if a file exists at `url`, optionally throwing if `throwOnMissingFiles` is `true`.
    ///
    /// - Parameter url: File URL to check.
    /// - Returns: `true` if file exists, otherwise `false`.
    /// - Throws: `TemplateLoadingError.fileNotFound` if missing and `throwOnMissingFiles == true`.
    private func ensureFileExists(at url: URL) throws -> Bool {
        if FileManager.default.fileExists(atPath: url.path) {
            // File does exist
            return true
        } else {
            // File missing
            if throwOnMissingFiles { throw TemplateLoadingError.fileNotFound(url: url) }
            
            return false
        }
    }
}
