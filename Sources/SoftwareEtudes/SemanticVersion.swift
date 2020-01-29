//
//  SemanticVersion.swift
//  
//
//  Created by Georg Tuparev on 29/01/2020.
//

import Foundation

/// `SemanticVersion` is a simple struct capturing the version of an app, module, framework, or
/// other resource.
///
/// `SemanticVersion` struct encapsulates the basic versioning rules for software modules. In
/// addition it can be used as application (tool) version as often defined in Info.plist.
///
/// Although the pre-release functionality (major version == 0) is supported, `SemanticVersion` does
/// not support versions denoted by appending a hyphen and a series of dot separated identifiers
/// immediately following the patch version.
///
///  For complete description of Semantic Version check https://semver.org
///
/// `NOTE`: Currently only regular versions are supported. Later versions will support alfa and beta versions (as in Swift Package Manager)
public struct SemanticVersion: Equatable, CustomStringConvertible, CustomDebugStringConvertible {

    /// Major version when there are make incompatible API or functionality changes
    public private(set) var majorNumber: UInt

    /// Minor version when API changes or functionality are added in a backwards-compatible manner
    public private(set) var minorNumber: UInt

    /// Patch version when backwards-compatible bug fixes are made
    public private(set) var patchNumber: UInt

    /// Initialises a new version with the provided major, minor, and patch numbers.
    /// - Parameters:
    ///    - majorNumber: indicates API or functionality changes, that are not backwards compatible.
    ///                   Required, no default value
    ///    - minorNumber: new API or functionality that are backwards compatible. Default value is 0
    ///    - patchNumber: improvements without API or functionality changes. Default value is 0
    /// - Returns: Always returns a newly created AppVersion.
    public init(majorNumber: UInt, minorNumber: UInt = 0, patchNumber: UInt = 0) {
        self.majorNumber = majorNumber
        self.minorNumber = minorNumber
        self.patchNumber = patchNumber
    }


    private static let allowedChars = CharacterSet(charactersIn: "0123456789.")

    /// This Initialiser does not support versions denoted by appending a hyphen and a series
    /// of dot separated identifiers
    public init?(with string: String) {
        let actualChars = CharacterSet(charactersIn: string)
        let numbers = string.components(separatedBy: ".")
        var versions: [UInt] = [0, 0, 0]
        var i = 0

        if (actualChars.isSubset(of: SemanticVersion.allowedChars)) && (numbers.count <= 3) {
            for verString in numbers {
                if verString.count == 0 { return nil }

                if let numb = UInt(verString) { versions[i] = numb }
                else { return nil }

                i += 1
            }
            self.init(majorNumber: versions[0], minorNumber: versions[1], patchNumber: versions[2])
        } else { return nil }
    }

    public var description: String { return "\(majorNumber).\(minorNumber).\(patchNumber)" }

    public var debugDescription: String { return "Version: \(description)" }

    //MARK: - Convenience methods to construct new versions

    /// Returns the next major version as defined by Semantic Versioning rules
    public func nextMajorVersion() -> SemanticVersion {
        return SemanticVersion(majorNumber: majorNumber + 1)
    }

    /// Returns the next minor version as defined by Semantic Versioning rules
    public func nextMinorVersion() -> SemanticVersion {
        return SemanticVersion(majorNumber: majorNumber, minorNumber: minorNumber + 1)
    }

    /// Returns the next patch version as defined by Semantic Versioning rules
    public func nextPatchVersion() -> SemanticVersion {
        return SemanticVersion(majorNumber: majorNumber, minorNumber: minorNumber, patchNumber:patchNumber + 1)
    }

}

extension SemanticVersion: Comparable {

    public static func < (left: SemanticVersion, right: SemanticVersion) -> Bool {
        if      left.majorNumber != right.majorNumber { return left.majorNumber < right.majorNumber }
        else if left.minorNumber != right.minorNumber { return left.minorNumber < right.minorNumber }
        else                                          { return left.patchNumber < right.patchNumber }
    }

}
