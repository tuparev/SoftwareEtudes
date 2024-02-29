//
//  FilesAndPaths.swift
//  
//
//  Created by Georg Tuparev on 04/02/2022.
//  Copyright © See Framework's LICENSE file
//

import Foundation

public extension URL {

    /// Returns App's default document directory
    ///
    /// This method is known to work only on macOS and iOS. It should work on other Apple platforms, but this is mot tested.
    static func documentsDirectory() -> URL {
        let paths              = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]

        return documentsDirectory
    }
}


public extension String {

    /// If `self` is supposed to be a path to a folder, it makes sure the last character is slash "/"
    ///
    /// If a `file://` type URL pointing to a folder is initialised with a string not ending with slash,
    /// some URLs returned by several ``Foundation/URL`` methods for some strange reason have no
    /// URL schema (and therefore are invalid). This method guarantees, that paths always end with a slash.
    func normalisedFolderPath() -> String {
        if self.hasSuffix("/") { return self }
        else                   { return "\(self)/" }
    }
}
