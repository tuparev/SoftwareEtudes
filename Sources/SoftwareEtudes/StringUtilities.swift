//
//  StringUtilities.swift
//  
//
//  Created by Georg Tuparev on 29/01/2020.
//  Copyright © 2020 Tuparev Technologies. All rights reserved.
//
//  Contributions, suggestions, ideas by:
//      1. Charles Parnot - @cparnot

import Foundation

/// These string enhancements are self explanatory. Nevertheless, it will be cool if someone writes proper documentation

//MARK: - Simplified substrings -
public extension String {

    func substring(from: Int = 0, to: Int? = nil) -> String {
        let start = from >= 0 ? from : 0
        guard start < self.count else { return "" }

        let startIndex = self.index(self.startIndex, offsetBy: start)

        let end = to ?? self.count
        guard end - start >= 0, end >= 0 else { return "" }

        let endIndex = end < self.count ? self.index(self.startIndex, offsetBy: end) : self.endIndex

        return  String(self[startIndex ..< endIndex])
    }

    func substring(from: Int = 0, length: Int) -> String {
        guard length > 0 else { return "" }

        let end: Int
        if from > 0 { end = from + length }
        else        { end = length }

        return self.substring(from: from, to: end)
    }

    func substring(length: Int, to: Int?) -> String {
        let end = to ?? self.count
        guard end > 0, length > 0 else { return "" }

        let start = end - length > 0 ? end - length : 0

        return self.substring(from: start, to: to)
    }
}

//MARK: - Miscellaneous -
public extension String {

    func containsOnly(character: Character) -> Bool {
        guard !self.isEmpty else { return false }

        let chars = Array(self)
        for ch in chars {
            if ch != character { return false }
        }
        return true
    }
}
