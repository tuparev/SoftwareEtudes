////
////  AbstractMessageInterpretingEnvironmentFileLoadingTests.swift
////  SoftwareEtudes
////
////  Created by Ani Klekchyan Work on 31.03.25.
////
import Testing
import Foundation
@testable import SoftwareEtudesCoreMessageDispatching

// MARK: - Base Template Loading Tests
struct BaseTemplateLoadingTests {
    var environment = AbstractMessageInterpretingEnvironment()
    // MARK: - Helper Methods
    
    /// Creates and returns a temporary directory URL.
    ///
    /// - Returns: A URL pointing to a newly created temporary folder.
    /// - Throws: An error if the folder cannot be created.
    func createTempFolder() throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        return tempDir
    }
    
    /// Deletes the temporary directory at the given URL.
    ///
    /// - Parameter url: The URL of the temporary directory to delete.
    func deleteTempFolder(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
    
    /// Copies a resource file from the package bundle into the given folder.
    ///
    /// This method looks for the resource file in the "TestData" subdirectory of the bundle.
    ///
    /// - Parameters:
    ///   - resourceName: The base name of the resource file (without extension).
    ///   - folder: The destination folder where the file will be copied.
    ///   - ext: The file extension (default is "json").
    ///   - subdirectory: The subdirectory in the bundle where the file is located (default is "TestData").
    /// - Throws: An error if the resource file cannot be found or copied.
    func copyResourceFile(
        named resourceName: String,
        to folder: URL,
        withExtension ext: String = "json",
        subdirectory: String? = "TestData"
    ) throws {
        let bundle = Bundle.module
        guard let resourceURL = bundle.url(
            forResource: resourceName,
            withExtension: ext,
            subdirectory: subdirectory
        ) else {
            throw NSError(
                domain: "MultiLanguageTemplateLoadingTests",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey:
                            "Missing resource file: \(resourceName).\(ext) in subdirectory \(subdirectory ?? "none")"]
            )
        }
        let destinationURL = folder.appendingPathComponent("\(resourceName).\(ext)")
        try FileManager.default.copyItem(at: resourceURL, to: destinationURL)
    }
}

//@Suite("English Tests")
struct TemplateLoadingEnglishTests {
    // Include the base as a stored property
    var base = BaseTemplateLoadingTests()
    
    // For convenience, you can use a computed property or direct references:
    var environment: AbstractMessageInterpretingEnvironment {
        get { base.environment }
        set { base.environment = newValue }
    }
    
    // MARK: - Test: English
    
    /// Tests that when the English resource files exist, they are correctly loaded and parsed.
    ///
    /// Expected behaviour:
    /// - The loaded filenames array should contain "codes_en.json" and "keys_en.json".
    /// - The environment’s coded and keyed template arrays should be populated.
    /// - Specific values (such as the code number and message text) should match the expected content.
    @Test
    func loadTemplatesForEnglish() throws {
        let tempFolderURL = try base.createTempFolder()
        defer { base.deleteTempFolder(at: tempFolderURL) }
        
        // Copy English resource files
        try base.copyResourceFile(named: "codes_en", to: tempFolderURL)
        try base.copyResourceFile(named: "keys_en", to: tempFolderURL)
        
        environment.languagePreferences = ["en"]
        
        let loadedFiles = try environment.loadAllTemplates(from: tempFolderURL)
        
        #expect(loadedFiles.contains("codes_en.json"))
        #expect(loadedFiles.contains("keys_en.json"))
        #expect(!environment.codedMessageTemplates.isEmpty)
        #expect(!environment.keyedMessageTemplates.isEmpty)
        
        // Check specifics
        guard let firstCoded = environment.codedMessageTemplates.first else {
            #expect(Bool(false), "Expected at least one coded message template")
            return
        }
        #expect(firstCoded.code == 100)
        #expect(firstCoded.messageTemplates["en"] == "Server Error: An unexpected error occurred.")
        
        guard let firstKeyed = environment.keyedMessageTemplates.first else {
            #expect(Bool(false), "Expected at least one keyed message template")
            return
        }
        #expect(firstKeyed.key == "logStart")
        #expect(firstKeyed.messageTemplates["en"] == "Logging initiated: System monitoring has started.")
    }
    
    @Test
    func autoLoadTemplates_successfullyLoadsEnglishTemplates() throws {
        let tempFolderURL = try base.createTempFolder()
        defer { base.deleteTempFolder(at: tempFolderURL) }
        
        // Provide config folder
        environment.configFolder = tempFolderURL
        
        // Copy English resource files
        try base.copyResourceFile(named: "codes_en", to: tempFolderURL)
        try base.copyResourceFile(named: "keys_en", to: tempFolderURL)
        
        environment.languagePreferences = ["en"]
        environment.ignoreMessagesWithoutTemplate = false
        
        do {
            try environment.autoLoadTemplates()
            #expect(!environment.codedMessageTemplates.isEmpty)
            #expect(!environment.keyedMessageTemplates.isEmpty)
        } catch {
            #expect(Bool(false), "Did not expect an error, but got: \(error)")
        }
    }
}

//@Suite("German Tests")
struct TemplateLoadingGermanTests {
    // Reference the base
    var base = BaseTemplateLoadingTests()
    
    var environment: AbstractMessageInterpretingEnvironment {
        get { base.environment }
        set { base.environment = newValue }
    }
    
    @Test
    func loadTemplatesForGermanFilesMissing_ignoreMessagesTrue_returnsEmpty() throws {
        let tempFolderURL = try base.createTempFolder()
        defer { base.deleteTempFolder(at: tempFolderURL) }
        
        // No resource files
        environment.languagePreferences = ["ge"]
        environment.ignoreMessagesWithoutTemplate = true
        
        let loadedFiles = try environment.loadAllTemplates(from: tempFolderURL)
        #expect(loadedFiles.isEmpty)
        #expect(environment.codedMessageTemplates.isEmpty)
        #expect(environment.keyedMessageTemplates.isEmpty)
    }
    
    @Test
    func loadTemplatesForGermanFilesMissing_ignoreMessagesFalse_throwsError() throws {
        let tempFolderURL = try base.createTempFolder()
        defer { base.deleteTempFolder(at: tempFolderURL) }
        
        environment.languagePreferences = ["ge"]
        environment.ignoreMessagesWithoutTemplate = false
        
        do {
            let _ = try environment.loadAllTemplates(from: tempFolderURL)
            #expect(Bool(false), "Expected an error due to missing German templates, but none was thown.")
        }
        catch AbstractMessageInterpretingEnvironment.TemplateLoadingError.noTemplatesFoundForPreferredLanguages(let langs) {
            let germanMissing = langs.contains("ge")
            #expect(germanMissing, "Expected 'ge' in the error languages, got: \(langs)")
        }
        catch {
            let msg = Comment(rawValue: "Expected TemplateLoadingError.noTemplatesFoundForPreferredLanguages, got: \(error)")
            #expect(Bool(false), msg)
        }
    }
}

@Suite("Preferred Languages Tests")
struct TemplateLoadingPreferredLanguagesTests {
    var base = BaseTemplateLoadingTests()
    
    var environment: AbstractMessageInterpretingEnvironment {
        get { base.environment }
        set { base.environment = newValue }
    }
    
    @Test
    func loadTemplatesForPreferredLanguages_whenFilesExist_returnsFilenames() throws {
        let tempFolderURL = try base.createTempFolder()
        defer { base.deleteTempFolder(at: tempFolderURL) }
        
        try base.copyResourceFile(named: "codes_en", to: tempFolderURL)
        try base.copyResourceFile(named: "keys_en", to: tempFolderURL)
        
        environment.languagePreferences = ["en"]
        let loadedFiles = try environment.loadTemplatesForPreferredLanguages(from: tempFolderURL)
        
        #expect(loadedFiles.contains("codes_en.json"))
        #expect(loadedFiles.contains("keys_en.json"))
    }
    
    @Test
    func loadTemplatesForPreferredLanguages_whenNoFilesExist_ignoreTrue_returnsEmpty() throws {
        let tempFolderURL = try base.createTempFolder()
        defer { base.deleteTempFolder(at: tempFolderURL) }
        
        environment.languagePreferences = ["en"]
        environment.ignoreMessagesWithoutTemplate = true
        
        let loadedFiles = try environment.loadTemplatesForPreferredLanguages(from: tempFolderURL)
        #expect(loadedFiles.isEmpty)
    }
    
    @Test
    func loadTemplatesForPreferredLanguages_whenNoFilesExist_ignoreFalse_throwsError() throws {
        let tempFolderURL = try base.createTempFolder()
        defer { base.deleteTempFolder(at: tempFolderURL) }
        
        environment.languagePreferences = ["ge"]
        environment.ignoreMessagesWithoutTemplate = false
        
        do {
            _ = try environment.loadTemplatesForPreferredLanguages(from: tempFolderURL)
            #expect(Bool(false), "Expected error due to missiValueng templatValuees, but none was thrown.")
        }
        catch AbstractMessageInterpretingEnvironment.TemplateLoadingError.noTemplatesFoundForPreferredLanguages(let langs) {
            let germanMissing = langs.contains("ge")
            #expect(germanMissing, "Expected 'ge' in error languages, got: \(langs)")
        }
        catch {
            let msg = Comment(rawValue: "Expected noTemplatesFoundForPreferredLanguages, got: \(error)")
            #expect(Bool(false), msg)
        }
    }
    
    @Test
    func loadTemplatesForPreferredLanguages_whenPartialFilesExist_returnsOnlyExistingFilenames() throws {
        let tempFolderURL = try base.createTempFolder()
        defer { base.deleteTempFolder(at: tempFolderURL) }
        
        // Copy only the coded file
        try base.copyResourceFile(named: "codes_en", to: tempFolderURL)
        
        environment.languagePreferences = ["en"]
        let loadedFiles = try environment.loadTemplatesForPreferredLanguages(from: tempFolderURL)
        
        #expect(loadedFiles.contains("codes_en.json"))
        #expect(!loadedFiles.contains("keys_en.json"))
    }
}

@Suite("Auto-Load Templates Tests")
struct AutoLoadTemplatesTests {
    var base = BaseTemplateLoadingTests()
    
    var environment: AbstractMessageInterpretingEnvironment {
        get { base.environment }
        set { base.environment = newValue }
    }
    
    /// Tests that when the configuration folder is not set, autoLoadTemplates() throws a
    /// TemplateLoadingError.configurationFolderNotSet error.
    @Test
    func autoLoadTemplates_configFolderNotSet_throwsError() throws {
        environment.configFolder = nil
        environment.languagePreferences = ["en"]
        
        do {
            try environment.autoLoadTemplates()
            #expect(Bool(false), "Expected configuration folder not set error, but none was thrown.")
        } catch AbstractMessageInterpretingEnvironment.TemplateLoadingError.configurationFolderNotSet {
            #expect(true)
        } catch {
            let msg = Comment(rawValue: "Expected configurationFolderNotSet error, got: \(error)")
            #expect(Bool(false), msg)
        }
    }
    
    /// Tests that when no template files exist and ignoreMessagesWithoutTemplate is true,
    /// autoLoadTemplates() completes without error and leaves the template arrays empty.
    @Test
    func autoLoadTemplates_whenNoFilesExist_ignoreMessagesTrue_returnsEmpty() throws {
        let tempFolderURL = try base.createTempFolder()
        defer { base.deleteTempFolder(at: tempFolderURL) }
        
        environment.configFolder = tempFolderURL
        environment.languagePreferences = ["en"]
        environment.ignoreMessagesWithoutTemplate = true
        
        do {
            try environment.autoLoadTemplates()
            #expect(environment.codedMessageTemplates.isEmpty)
            #expect(environment.keyedMessageTemplates.isEmpty)
        } catch {
            #expect(Bool(false), "Did not expect an error, but got: \(error)")
        }
    }
    
    /// Tests that when no template files exist and ignoreMessagesWithoutTemplate is false,
    /// autoLoadTemplates() throws a noTemplatesFoundForPreferredLanguages error.
    @Test
    func autoLoadTemplates_whenNoFilesExist_ignoreMessagesFalse_throwsError() throws {
        let tempFolderURL = try base.createTempFolder()
        defer { base.deleteTempFolder(at: tempFolderURL) }
        
        environment.configFolder = tempFolderURL
        environment.languagePreferences = ["ge"]
        environment.ignoreMessagesWithoutTemplate = false
        
        do {
            _ = try environment.autoLoadTemplates()
            #expect(Bool(false), "Expected error due to missing templates, but none was thrown.")
        } catch AbstractMessageInterpretingEnvironment.TemplateLoadingError.noTemplatesFoundForPreferredLanguages(let langs) {
            let germanMissing = langs.contains("ge")
            #expect(germanMissing, "Expected 'ge' in error languages, got: \(langs)")
        } catch {
            let msg = Comment(rawValue: "Expected noTemplatesFoundForPreferredLanguages, got: \(error)")
            #expect(Bool(false), msg)
        }
    }
    
    /// Tests that when a partial set of files exist (only the coded templates),
    /// loadTemplatesForPreferredLanguages(from:) returns only the filenames for the existing files.
    @Test
    func loadTemplatesForPreferredLanguages_whenPartialFilesExist_returnsOnlyExistingFilenames() throws {
        let tempFolderURL = try base.createTempFolder()
        defer { base.deleteTempFolder(at: tempFolderURL) }
        
        // Copy only the coded template file; do not copy keys_en.json.
        try base.copyResourceFile(named: "codes_en", to: tempFolderURL)
        // keys_en.json is intentionally not copied.
        
        environment.languagePreferences = ["en"]
        let loadedFiles = try environment.loadTemplatesForPreferredLanguages(from: tempFolderURL)
        #expect(loadedFiles.contains("codes_en.json"))
        #expect(!loadedFiles.contains("keys_en.json"))
    }
    
    /// Tests that when the defaults file exists in the configuration folder,
    /// autoLoadTemplates() loads the default settings and updates the default messages.
    ///
    /// Expected behavior:
    /// - The coded and keyed template arrays are populated (if corresponding templates exist).
    /// - The environment's defaultUnknownKeyMessage and defaultUnknownCodeMessage properties are updated
    ///   to the values specified in the defaults.json file.
    ///
    /// - Throws: An error if temporary folder creation or file copying fails.
    @Test
    func autoLoadTemplates_successfullyLoadsTemplatesAndDefaults() throws {
        let tempFolderURL = try base.createTempFolder()
        defer { base.deleteTempFolder(at: tempFolderURL) }
        environment.configFolder = tempFolderURL
        
        // Copy resource files from the "TestData" folder.
        try base.copyResourceFile(named: "codes_en", to: tempFolderURL)
        try base.copyResourceFile(named: "keys_en", to: tempFolderURL)
        try base.copyResourceFile(named: "defaults", to: tempFolderURL)
        // Expected that defaults.json contains:
        // { "unknownKeyMessage": "Default: Key not found.", "unknownCodeMessage": "Default: Code unknown." }
        
        environment.languagePreferences = ["en"]
        environment.ignoreMessagesWithoutTemplate = false
        
        do {
            try environment.autoLoadTemplates()
            #expect(!environment.codedMessageTemplates.isEmpty)
            #expect(!environment.keyedMessageTemplates.isEmpty)
            #expect(environment.defaultUnknownKeyMessage == "Default: Key not found.")
            #expect(environment.defaultUnknownCodeMessage == "Default: Code unknown.")
        } catch {
            #expect(Bool(false), "Did not expect an error, but got: \(error)")
        }
    }
}
