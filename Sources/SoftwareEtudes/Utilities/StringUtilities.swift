//
//  StringUtilities.swift
//  
//
//  Created by Georg Tuparev on 29/01/2020.
//  Copyright © 2020 Tuparev Technologies. All rights reserved.
//
//  Thanks for contributions, suggestions, ideas by:
//      1. Charles Parnot - @cparnot
//      2. serg_zhd answers at stackoverflow.com

import Foundation

/// These string enhancements are self explanatory. Nevertheless, it will be cool if someone writes proper documentation

//MARK: - Simplified substrings -
public extension String {

    func between(_ left: String, _ right: String) -> String? {
        guard let leftRange = range(of: left), let rightRange = range(of: right, options: .backwards), leftRange.upperBound <= rightRange.lowerBound else { return nil }

        let subRange           = self[leftRange.upperBound...]
        let closestToLeftRange = subRange.range(of: right)!

        return String(subRange[..<closestToLeftRange.lowerBound])
    }

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

    func replaceMatchesFrom(dictionary: [String : String], startMarker: String = "<@", endMarker: String = "@>", noMachString: String = "NO MATCH") -> String {
        var (tempString, hasMatch): (String, Bool) = (self, false)

        repeat {
            (tempString, hasMatch) = tempString.replaceMatchesFrom(dictionary: dictionary, startMarker: startMarker, endMarker: endMarker, noMachString: noMachString)
        } while hasMatch

        return tempString
    }

    private func replaceMatchesFrom(dictionary: [String : String], startMarker: String = "<@", endMarker: String = "@>", noMachString: String = "NO MATCH") -> (result: String, hasMatch: Bool) {
        guard var matchCandidate = self.between(startMarker, endMarker) else { return (self, false) }
        let replacement = dictionary[matchCandidate] ?? noMachString

        matchCandidate = "\(startMarker)\(matchCandidate)\(endMarker)"

        return (self.replacingOccurrences(of: matchCandidate, with: replacement), true)
    }
}
