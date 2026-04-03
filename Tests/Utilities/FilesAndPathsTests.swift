//
//  FilesAndPathsTests.swift
//
//
//  Created by Ani Klekchyan on 03.04.26.
//  Copyright © See Framework's LICENSE file
//

import Testing
import Foundation
@testable import SoftwareEtudesUtilities

@Suite("FilesAndPaths")
struct FilesAndPathsTests {

    // MARK: - URL.documentsDirectory()

    @Suite("URL.documentsDirectory()")
    struct DocumentsDirectory {

        @Test("returns a valid URL")
        func returnsValidURL() {
            let url = URL.documentsDirectory()
            #expect(!url.path.isEmpty)
        }

        @Test("returned URL is a file URL")
        func returnsFileURL() {
            #expect(URL.documentsDirectory().isFileURL)
        }

        @Test("returns same URL on repeated calls")
        func isConsistent() {
            #expect(URL.documentsDirectory() == URL.documentsDirectory())
        }
    }

    // MARK: - String.normalisedFolderPath()

    @Suite("String.normalisedFolderPath()")
    struct NormalisedFolderPath {

        @Test("path without trailing slash gets one appended")
        func appendsSlash() {
            #expect("/Users/me/Documents".normalisedFolderPath() == "/Users/me/Documents/")
        }

        @Test("path already ending with slash is returned unchanged")
        func alreadyNormalised() {
            #expect("/Users/me/Documents/".normalisedFolderPath() == "/Users/me/Documents/")
        }

        @Test("empty string becomes single slash")
        func emptyString() {
            #expect("".normalisedFolderPath() == "/")
        }

        @Test("single slash is returned unchanged")
        func singleSlash() {
            #expect("/".normalisedFolderPath() == "/")
        }

        @Test("relative path without slash gets one appended")
        func relativePath() {
            #expect("logs".normalisedFolderPath() == "logs/")
        }

        @Test("calling twice is idempotent")
        func idempotent() {
            let path = "/some/path"
            #expect(path.normalisedFolderPath() == path.normalisedFolderPath().normalisedFolderPath())
        }
    }
}
