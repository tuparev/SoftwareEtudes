//
//  SemanticVersion.swift
//  
//
//  Created by Georg Tuparev on 29/01/2020.
//  Copyright © See Framework's LICENSE file
//

import Foundation

/// `SemanticVersion` is a simple type capturing the version of an app, module, framework, or other resource.
///
/// `SemanticVersion` struct encapsulates the basic versioning rules for software modules. One can use this
/// implementation to access app version as defined in Info.plist. Because SemanticVersion implements the
/// `Equatable` protocol, this struct is useful in cases when exposing certain functionality is linked to a
/// a particular app version.
///
/// `SemanticVersion` implements `Codable` protocol while encoding to and decoding from a String to produce more
/// readable JSON notation.
///
///  For complete description check the official definition of [Semantic Versioning](https://semver.org)
public struct SemanticVersion: Equatable, CustomStringConvertible, CustomDebugStringConvertible, Codable, Hashable {

    /// Checks if a string is proper version string
    ///
    /// This method could be used to check a string is a valid Semantic version string. Valid examples include:
    ///    - "1.0.0"
    ///    - "0.5.17-alpha.1"
    ///    - "0.5.17-beta.1+1234.alpha"
    /// - Parameter string: string to be validated
    /// - Returns: `true` if the string is a valid semantic version string, otherwise - `false`
    public static func isValid(version string: String) -> Bool {
        let regExString = #"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$"#
        let regEx       = NSPredicate(format:"SELF MATCHES %@", regExString)

        return regEx.evaluate(with: string)
    }

    /// Major version.
    ///
    /// Incremented when there are incompatible API or functionality changes.
    public private(set) var majorNumber: UInt

    /// Minor version.
    ///
    /// Incremented when there are API changes added in a backwards-compatible manner.
    public private(set) var minorNumber: UInt

    /// Patch version.
    ///
    /// Incremented when only when bugs are fixed, or other optimisations or improvements are added, but there
    /// are no API changes.
    public private(set) var patchNumber: UInt

    /// Pre-release string.
    ///
    /// A pre-release version may be denoted by appending a hyphen (`-`) and a series of dot (`"."`) separated identifiers
    /// immediately following the patch version. Identifiers must comprise only ASCII alphanumerics and hyphens and
    /// cannot be be empty. Pre-release versions have a lower precedence than the associated normal version. A pre-release
    /// version indicates that the version is unstable and might not satisfy the intended compatibility requirements as
    /// denoted by its associated normal version. Alpha and Beta are commonly used identifiers.
    /// Commonly used examples include:
    /// - "-alpha"
    /// - "-beta"
    /// - "-beta.2"
    public private(set) var preRelease: String?

    /// Build metadata string.
    ///
    /// Build metadata may be denoted by appending a plus sign (`+`) and a series of dot (`.`) separated identifiers
    /// immediately following the patch or pre-release version. Identifiers must comprise only ASCII alphanumerics and
    /// hyphens. Build metadata is ignored when determining version precedence.
    public private(set) var buildMetadata: String?

    /// Creates an instance from version components
    ///
    /// Always creates an instance. Most of the components could be omitted.
    /// - Parameters:
    ///   - majorNumber: A required zero or positive integer number.
    ///   - minorNumber: An optional zero or positive integer number.
    ///   - patchNumber: An optional zero or positive integer number.
    ///   - preReleaseVersion: An optional string indicating a pre-release version.
    public init(majorNumber: UInt,
                minorNumber: UInt          = 0,
                patchNumber: UInt          = 0,
                preReleaseVersion: String? = nil,
                buildMetadata: String?     = nil) {
        self.majorNumber   = majorNumber
        self.minorNumber   = minorNumber
        self.patchNumber   = patchNumber
        self.preRelease    = preReleaseVersion
        self.buildMetadata = buildMetadata
    }


    /// Creates an instance from string
    ///
    /// Creates a new version with  major, minor, patch numbers, and optional pre-release and / or build metadata strings.
    /// Besides valid Semantic Version strings, it is possible to use short version strings like "1", or "0.4".
    ///
    /// Valid examples are:
    ///  - "3"
    ///  - "0.4"
    ///  - "0.4-alpha"
    ///  - "1.0.3"
    ///  - "1.0.3-beta.4"
    ///  - "1.0.3-beta.4+1214-alpha"
    ///  - "1.0.3+1214-alpha.1"
    /// - Parameters:
    ///    - with: A version string.
    /// - Returns: if the version string is valid, it returns a newly created instance. Otherwise it returns `nil`
    public init?(with string: String) {
        var parts          = string.components(separatedBy: "+")
        var precedencePart = ""
        var version        = ""
        var preRelease     = ""
        var buildMeta      = ""

        // Extracting the Build Metadata
        if      parts.isEmpty || (parts.count > 2) { return nil }
        else if parts.count == 2 {
            buildMeta = parts[1]
        }
        precedencePart = parts[0]

        // Extraction the Pre-release string
        parts = precedencePart.components(separatedBy: "-")

        if parts.isEmpty { return nil }
        else {
            version = parts.removeFirst()
            if !parts.isEmpty { preRelease = parts.joined(separator: "-")}
        }

        var numbers = version.components(separatedBy: ".")

        if      numbers.count == 1 { version.append(".0.0") }
        else if numbers.count == 2 { version.append(".0") }
        else if numbers.count > 3  { return nil }
        numbers = version.components(separatedBy: ".")

        var stringToValidate = preRelease.isEmpty ? version : "\(version)-\(preRelease)"
        stringToValidate     = buildMeta.isEmpty  ? stringToValidate : "\(stringToValidate)+\(buildMeta)"

        if SemanticVersion.isValid(version: stringToValidate) {
            guard let maj = UInt(numbers[0]), let min = UInt(numbers[1]), let patch = UInt(numbers[2]) else { return nil }

            self.init(majorNumber: maj, minorNumber: min, patchNumber: patch)
            if !preRelease.isEmpty { self.preRelease    = preRelease }
            if !buildMeta.isEmpty  { self.buildMetadata = buildMeta }
        }
        else { return nil }
    }

    public init(from decoder: Decoder) throws {
        let strDecoder = try decoder.singleValueContainer()
        let str        = try strDecoder.decode(String.self)
        let sVar       = SemanticVersion(with: str)

        self.majorNumber   = sVar!.majorNumber
        self.minorNumber   = sVar!.minorNumber
        self.patchNumber   = sVar!.patchNumber
        self.preRelease    = sVar!.preRelease
        self.buildMetadata = sVar!.buildMetadata
    }

    public func encode(to encoder: Encoder) throws {
        try description.encode(to: encoder)
    }

    public var description: String {
        var result = "\(majorNumber).\(minorNumber).\(patchNumber)"

        if !(preRelease?.isEmpty ?? true)    { result.append("-\(preRelease!)") }
        if !(buildMetadata?.isEmpty ?? true) { result.append("+\(buildMetadata!)") }

        return result
    }

    public var debugDescription: String { "Semantic version: \(description)" }

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
        else if left.patchNumber != right.patchNumber { return left.patchNumber < right.patchNumber }

        if (left.preRelease == nil) && (right.preRelease != nil) { return false }
        if (left.preRelease != nil) && (right.preRelease != nil) { return left.preRelease! < right.preRelease! }

        return false
    }

}
