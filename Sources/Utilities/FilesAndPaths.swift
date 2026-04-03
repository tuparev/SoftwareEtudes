//
//  FilesAndPaths.swift
//
//
//  Created by Georg Tuparev on 04/02/2022.
//  Copyright © See Framework's LICENSE file
//
//  Utilities for working with file-system paths and well-known directories.
//

import Foundation

public extension URL {

    /// Returns the app's default document directory.
    ///
    /// On all Apple platforms, `FileManager` is guaranteed to return at least
    /// one URL for `.documentDirectory` in `.userDomainMask`, so the index
    /// access `[0]` is safe.
    ///
    /// - Note: Verified on macOS and iOS. Expected to work on tvOS, watchOS,
    ///   and visionOS, though this has not been formally tested on those
    ///   platforms.
    /// - Returns: The URL of the user's Documents directory.
    static func documentsDirectory() -> URL {
        let paths              = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]

        return documentsDirectory
    }
}

public extension String {

    /// Returns a copy of the string guaranteed to end with a trailing slash.
    ///
    /// When initialising a `file://` URL that points to a directory, the path
    /// string **must** end with `/` — otherwise several `Foundation.URL`
    /// methods return URLs without a scheme (and are therefore invalid).
    ///
    ///     "/Users/me/Documents".normalisedFolderPath()   // "/Users/me/Documents/"
    ///     "/Users/me/Documents/".normalisedFolderPath()  // "/Users/me/Documents/"  (no-op)
    ///     "".normalisedFolderPath()                      // "/"
    ///
    /// - Returns: The original string if it already ends with `/`, otherwise
    ///   the string with `/` appended.
    func normalisedFolderPath() -> String {
        if self.hasSuffix("/") { return self }
        else                   { return "\(self)/" }
    }
}
