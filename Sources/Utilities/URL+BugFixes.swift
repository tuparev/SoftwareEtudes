//
//  URL+BugFixes.swift
//
//
//  Created by Georg Tuparev on 23/08/2023.
//  Copyright © See Framework's LICENSE file
//

import Foundation

public extension URL {

    /// In macOS Sonoma (beta) URL's `hasDirectoryPath` is broken. And hasDirectoryPath is a stupid name, so here a fix
    func isDirectoryPath() -> Bool {
        let fm              = FileManager.default
        var isDir: ObjCBool = false

        return fm.fileExists(atPath: self.path(), isDirectory: &isDir) && (isDir.boolValue)
    }
}
