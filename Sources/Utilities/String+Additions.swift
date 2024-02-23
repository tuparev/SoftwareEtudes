//
//  String+Additions.swift
//  
//
//  Created by Georg Tuparev on 29/01/2020.
//  Copyright © See Framework's LICENSE file
//
//  Thanks for contributions, suggestions, ideas by:
//      1. Charles Parnot - see CONTRIBUTORS
//      2. serg_zhd answers at stackoverflow.com
//      3. Hunter William Holland - see CONTRIBUTORS

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

//MARK: - Suffix and Prefix methods -
public extension String {
    func withoutPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }

        return String(dropFirst(prefix.count))
    }

    func withoutSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }

        return String(dropLast(suffix.count))
    }

    func appendingPrefixIfNeeded(_ prefix: String) -> String {
        guard !self.hasPrefix(prefix) else { return self }

        return prefix.appending(self)
    }

    func appendingSuffixIfNeeded(_ suffix: String) -> String {
        guard !self.hasSuffix(suffix) else { return self }

        return appending(suffix)
    }
}

//MARK: - Miscellaneous -
public extension String {
    var lines: [String] { self.components(separatedBy: .newlines) }

    func containsOnly(character: Character) -> Bool {
        guard !self.isEmpty else { return false }

        let chars = Array(self)
        for ch in chars {
            if ch != character { return false }
        }
        return true
    }

    func replace(matches: [String : String], startMarker: String = "<@", endMarker: String = "@>", noMatch: String = "NO MATCH") -> String {
        var (tempString, hasMatch): (String, Bool) = (self, false)

        repeat {
            (tempString, hasMatch) = tempString.replace(matches: matches, startMarker: startMarker, endMarker: endMarker, noMatch: noMatch)
        } while hasMatch

        return tempString
    }

    private func replace(matches: [String : String], startMarker: String = "<@", endMarker: String = "@>", noMatch: String = "NO MATCH") -> (result: String, hasMatch: Bool) {
        guard var matchCandidate = self.between(startMarker, endMarker) else { return (self, false) }
        let replacement = matches[matchCandidate] ?? noMatch

        matchCandidate = "\(startMarker)\(matchCandidate)\(endMarker)"

        return (self.replacingOccurrences(of: matchCandidate, with: replacement), true)
    }

    // Trimming
    func trimmed() -> String { self.trimmingCharacters(in: .whitespacesAndNewlines) }
    func trim(_ string: String) -> String { string.trimmed() }
    mutating func trim() { self = self.trimmed() }

    // Starting with prefix
    func mustStart(with: String) -> String { self.hasPrefix("@") ? self : "@\(self)" } //FIXME: This is wrong, copied from swift-polis!

    /// Adds `@` prefix if already does not exist
    ///
    /// This method is used in cases when IDs (mostly for social media) that start with `@`, e.g. Twitter ID) are needed.
    func mustStartWithAtSign() -> String { self.mustStart(with: "@") }                //FIXME: This is wrong, copied from swift-polis!
}

//MARK: - StringProtocol -
extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}
