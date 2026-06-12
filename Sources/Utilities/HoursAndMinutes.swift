//
//  HoursAndMinutes.swift
//  SoftwareEtudes
//
//  Created by Georg Tuparev on 12/06/2026.
//

import Foundation

/// Represents a time given as hours and minutes of a 24-hour clock.
///
/// Valid hours are 0 through 23, and valid minutes are 0 through 59.
/// Initialization performs validation and can throw if values are out of range.
///
/// Supports parsing from string formats including:
/// ```
/// "17h 13m"
/// "17:13pm"
/// "5:13am"
/// "05:13am"
/// ```
///
/// Also supports various string formatting styles, including localized formats.
///
/// Example usage:
/// ```swift
/// let time = try HoursAndMinutes(hours: 17, minutes: 13)
/// print(time.formatted(.hM)) // "17h 13m"
/// let parsed = try HoursAndMinutes("5:13am")
/// print(parsed.hours)  // 5
/// print(parsed.minutes) // 13
/// ```
public struct HoursAndMinutes: Codable, Equatable {
    /// The hour component (0...23).
    ///
    /// Hours must be within the range 0 to 23 inclusive.
    /// Values are validated on initialization.
    public var hours: Int
    
    /// The minute component (0...59).
    ///
    /// Minutes must be within the range 0 to 59 inclusive.
    /// Values are validated on initialization.
    public var minutes: Int
    
    /// Formatting styles for `HoursAndMinutes`.
    ///
    /// Use these to specify the output format when calling `formatted(_:, options:)`.
    public enum Style: Codable, Equatable {
        /// Format like `"17h 13m"`.
        case hM
        
        /// 24-hour format with colon, e.g. `"17:13"`.
        case colon24
        
        /// 24-hour format with lowercase "am"/"pm" suffix, e.g. `"17:13pm"`.
        case colon24WithSuffix
        
        /// 12-hour clock with lowercase suffix, no leading zero on hour, e.g. `"5:13am"`.
        case twelveHour
        
        /// 12-hour clock with lowercase suffix, padded hour, e.g. `"05:13am"`.
        case twelveHourPadded
        
        /// 12-hour clock with uppercase suffix and space separator, e.g. `"5:13 AM"`.
        case twelveHourUppercase
        
        /// Localized short time style (DateFormatter).
        case localizedShort
        
        /// Localized medium time style (DateFormatter).
        case localizedMedium
        
        /// Localized long time style (DateFormatter).
        case localizedLong
        
        /// Localized full time style (DateFormatter).
        case localizedFull
        
        /// Localized short date + short time style (DateFormatter).
        case localizedDateTimeShort
        
        /// Localized medium date + medium time style (DateFormatter).
        case localizedDateTimeMedium
        
        /// Localized long date + long time style (DateFormatter).
        case localizedDateTimeLong
        
        /// Localized full date + full time style (DateFormatter).
        case localizedDateTimeFull
    }

    /// Options to customize rendering of 12-hour and 24-hour suffixes.
    ///
    /// Combine options to modify suffix case, spacing, or hour padding.
    public struct Options: OptionSet, Codable {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
        
        /// Use uppercase "AM"/"PM" suffix instead of lowercase.
        public static let uppercaseSuffix = Options(rawValue: 1 << 0)
        
        /// Insert a space before the AM/PM suffix.
        public static let spacedSuffix = Options(rawValue: 1 << 1)
        
        /// Pad 12-hour clock hour with leading zero.
        public static let padTwelveHour = Options(rawValue: 1 << 2)
    }
    
    /// Validates that hours and minutes are within acceptable ranges.
    ///
    /// - Throws: `HoursAndMinutesError.invalidHours` if hours are out of 0...23.
    ///           `HoursAndMinutesError.invalidMinutes` if minutes are out of 0...59.
    @inline(__always)
    private static func validate(hours: Int, minutes: Int) throws {
        guard (0...23).contains(hours) else { throw HoursAndMinutesError.invalidHours(hours) }
        guard (0...59).contains(minutes) else { throw HoursAndMinutesError.invalidMinutes(minutes) }
    }
    
    /// Errors that can occur when working with `HoursAndMinutes`.
    ///
    /// - `invalidHours`: Hour value was outside 0...23.
    /// - `invalidMinutes`: Minute value was outside 0...59.
    /// - `invalidFormat`: Input string parsing failed due to unexpected format.
    public enum HoursAndMinutesError: Error, LocalizedError, Codable, Equatable {
        case invalidHours(Int)
        case invalidMinutes(Int)
        case invalidFormat(String)

        public var errorDescription: String? {
            switch self {
            case .invalidHours(let h): return "Invalid hours: \(h). Expected 0...23."
            case .invalidMinutes(let m): return "Invalid minutes: \(m). Expected 0...59."
            case .invalidFormat(let s): return "Invalid time format: \(s)."
            }
        }
    }
    
    /// Creates a new `HoursAndMinutes` with validated hours and minutes.
    ///
    /// - Parameters:
    ///   - hours: Hour value in 0...23.
    ///   - minutes: Minute value in 0...59.
    /// - Throws: `HoursAndMinutesError` if values are out of range.
    public init(hours: Int, minutes: Int) throws {
        try Self.validate(hours: hours, minutes: minutes)
        self.hours = hours
        self.minutes = minutes
    }
    
    /// Creates a new `HoursAndMinutes` by parsing a string.
    ///
    /// Supported input formats include (case-insensitive, optional spaces):
    /// - `"17h 13m"` (hours and minutes with `h` and `m` suffixes)
    /// - `"17:13pm"` (24-hour colon format with am/pm suffix)
    /// - `"5:13am"` (12-hour colon format with am/pm suffix)
    /// - `"05:13am"` (12-hour colon format with padded hour)
    ///
    /// Examples:
    /// ```swift
    /// try HoursAndMinutes("17h 13m")
    /// try HoursAndMinutes("5:13am")
    /// try HoursAndMinutes("12:00pm")
    /// ```
    ///
    /// - Parameter string: Input time string.
    /// - Throws: `HoursAndMinutesError.invalidFormat` if string format is invalid.
    public init(_ string: String) throws {
        let original = string
        let s = string.trimmingCharacters(in: .whitespacesAndNewlines)

        // Try format: 17h 13m (optional space)
        if let match = s.range(of: "^\\s*([0-9]{1,2})\\s*[hH]\\s*([0-9]{1,2})\\s*[mM]\\s*$", options: .regularExpression) {
            let sub = String(s[match])
            let parts = try HoursAndMinutes.extract(using: "^\\s*([0-9]{1,2})\\s*[hH]\\s*([0-9]{1,2})\\s*[mM]\\s*$", from: sub)
            let h = Int(parts[0])!
            let m = Int(parts[1])!
            try self.init(hours: h, minutes: m)
            return
        }

        // Try format: 17:13am/pm (am or pm suffix optional but if present must be a/A or p/P)
        if let match = s.range(of: "^\\s*([0-9]{1,2}):([0-9]{1,2})([aA]|[pP])[mM]?\\s*$", options: .regularExpression) {
            let sub = String(s[match])
            let parts = try HoursAndMinutes.extract(using: "^\\s*([0-9]{1,2}):([0-9]{1,2})([aA]|[pP])[mM]?\\s*$", from: sub)
            var h = Int(parts[0])!
            let m = Int(parts[1])!
            let suffix = parts.count >= 3 ? parts[2].lowercased() : ""
            let hasSuffix = !suffix.isEmpty
            if hasSuffix && suffix != "a" && suffix != "p" {
                throw HoursAndMinutesError.invalidFormat(original)
            }
            if suffix == "p" {
                // For pm, 1pm..11pm => +12; 12pm => 12; 0pm is invalid
                if h == 0 { throw HoursAndMinutesError.invalidFormat(original) }
                if h >= 1 && h <= 11 { h += 12 }
                // if h == 12, keep 12
            } else if suffix == "a" {
                // For am, 12am => 0; 0am => 0; 1am..11am keep as is
                if h == 12 {
                    h = 0
                }
                // h == 0 or 1...11 keep as is
            }
            try self.init(hours: h, minutes: m)
            return
        }

        throw HoursAndMinutesError.invalidFormat(original)
    }
    
    /// Helper method to capture regex groups from a string.
    ///
    /// - Parameters:
    ///   - pattern: Regular expression pattern.
    ///   - s: Input string.
    /// - Returns: Array of captured groups as strings.
    /// - Throws: If regex pattern is invalid.
    private static func extract(using pattern: String, from s: String) throws -> [String] {
        let regex = try NSRegularExpression(pattern: pattern)
        guard let m = regex.firstMatch(in: s, range: NSRange(location: 0, length: (s as NSString).length)) else { return [] }
        var results: [String] = []
        for i in 1..<m.numberOfRanges { // capture groups only
            let r = m.range(at: i)
            if r.location != NSNotFound, let range = Range(r, in: s) {
                results.append(String(s[range]))
            } else {
                results.append("")
            }
        }
        return results
    }
    
    /// Returns a string formatted as "17h 13m".
    public var hMString: String { "\(hours)h \(minutes)m" }
    
    /// Returns a string formatted as "17:13" (24-hour, zero-padded).
    public var colonString: String { String(format: "%02d:%02d", hours, minutes) }
    
    /// Returns a string formatted as "17:13pm" (24-hour with lowercase suffix).
    public var colonPMString: String { "\(colonString)pm" }
    
    /// Returns a string formatted as "17:13am" (24-hour with lowercase suffix).
    public var colonAMString: String { "\(colonString)am" }
    
    /// Returns a string formatted as "05:13pm" or "05:13am" (12-hour padded with lowercase suffix).
    public var colonAMPMString: String {
        let isPM = hours >= 12
        let hour12 = hours == 0 ? 12 : (hours > 12 ? hours - 12 : hours)
        let suffix = isPM ? "pm" : "am"
        return String(format: "%02d:%02d%@", hour12, minutes, suffix)
    }

    /// 12-hour clock string like "5:03am" (no leading zero for hour).
    public var twelveHourString: String {
        let isPM = hours >= 12
        let hour12 = hours == 0 ? 12 : (hours > 12 ? hours - 12 : hours)
        let suffix = isPM ? "pm" : "am"
        return String(format: "%d:%02d%@", hour12, minutes, suffix)
    }

    /// 12-hour clock string like "05:03am" (leading zero for hour).
    public var twelveHourPaddedString: String {
        let isPM = hours >= 12
        let hour12 = hours == 0 ? 12 : (hours > 12 ? hours - 12 : hours)
        let suffix = isPM ? "pm" : "am"
        return String(format: "%02d:%02d%@", hour12, minutes, suffix)
    }

    /// 12-hour clock string like "5:03 AM" (uppercase suffix with space separator).
    public var twelveHourUppercaseString: String {
        let isPM = hours >= 12
        let hour12 = hours == 0 ? 12 : (hours > 12 ? hours - 12 : hours)
        let suffix = isPM ? "PM" : "AM"
        return String(format: "%d:%02d %@", hour12, minutes, suffix)
    }

    /// Returns a formatted string for this time using the given style and options.
    ///
    /// - Parameters:
    ///   - style: The formatting style (see `Style`).
    ///   - options: Formatting options to customize suffix case, spacing, and padding.
    ///
    /// - Returns: A string representing the time formatted accordingly.
    ///
    /// Example:
    /// ```swift
    /// let time = try HoursAndMinutes(hours: 5, minutes: 3)
    /// let formatted = time.formatted(.twelveHourUppercase, options: [.spacedSuffix])
    /// print(formatted) // "5:03 AM"
    /// ```
    public func formatted(_ style: Style, options: Options = []) -> String {
        switch style {
        case .localizedShort, .localizedMedium, .localizedLong, .localizedFull,
             .localizedDateTimeShort, .localizedDateTimeMedium, .localizedDateTimeLong, .localizedDateTimeFull:
            return formattedLocalized(style)
        case .hM:
            return "\(hours)h \(minutes)m"
        case .colon24:
            return String(format: "%02d:%02d", hours, minutes)
        case .colon24WithSuffix:
            let isPM = hours >= 12
            let suffix = (options.contains(.uppercaseSuffix) ? (isPM ? "PM" : "AM") : (isPM ? "pm" : "am"))
            let sep = options.contains(.spacedSuffix) ? " " : ""
            return String(format: "%02d:%02d%@%@", hours, minutes, sep, suffix)
        case .twelveHour, .twelveHourPadded, .twelveHourUppercase:
            let isPM = hours >= 12
            let hour12 = hours == 0 ? 12 : (hours > 12 ? hours - 12 : hours)
            let usePad = style == .twelveHourPadded || options.contains(.padTwelveHour)
            let upper = style == .twelveHourUppercase || options.contains(.uppercaseSuffix)
            let suffix = upper ? (isPM ? "PM" : "AM") : (isPM ? "pm" : "am")
            let sep = options.contains(.spacedSuffix) || style == .twelveHourUppercase ? " " : ""
            if usePad {
                return String(format: "%02d:%02d%@%@", hour12, minutes, sep, suffix)
            } else {
                return String(format: "%d:%02d%@%@", hour12, minutes, sep, suffix)
            }
        }
    }

    /// Formats the time using localized date and time styles.
    ///
    /// Uses `DateFormatter` to produce localized strings based on the style parameter.
    /// The date is fixed to January 1, 2000 for consistent time-only display.
    ///
    /// - Parameters:
    ///   - style: One of the `.localized*` formatting styles.
    ///   - locale: Optional locale override (defaults to current locale).
    ///   - timeZone: Optional time zone override (defaults to current time zone).
    ///
    /// - Returns: A localized time or date-time string.
    ///
    /// Example:
    /// ```swift
    /// let time = try HoursAndMinutes(hours: 14, minutes: 30)
    /// let localized = time.formattedLocalized(.localizedShort, locale: Locale(identifier: "fr_FR"))
    /// print(localized) // "14:30" in French locale formatting
    /// ```
    public func formattedLocalized(_ style: Style, locale: Locale? = nil, timeZone: TimeZone? = nil) -> String {
        let df = DateFormatter()
        df.dateStyle = .none // default dateStyle
        switch style {
        case .localizedShort:
            df.timeStyle = .short
        case .localizedMedium:
            df.timeStyle = .medium
        case .localizedLong:
            df.timeStyle = .long
        case .localizedFull:
            df.timeStyle = .full
        case .localizedDateTimeShort:
            df.dateStyle = .short
            df.timeStyle = .short
        case .localizedDateTimeMedium:
            df.dateStyle = .medium
            df.timeStyle = .medium
        case .localizedDateTimeLong:
            df.dateStyle = .long
            df.timeStyle = .long
        case .localizedDateTimeFull:
            df.dateStyle = .full
            df.timeStyle = .full
        default:
            // Fallback to medium if non-localized style is passed inadvertently
            df.timeStyle = .medium
        }
        if let locale { df.locale = locale }
        if let timeZone { df.timeZone = timeZone }

        // Build a reference date with the given hours/minutes in the chosen time zone.
        var calendar = Calendar(identifier: .gregorian)
        if let tz = df.timeZone { calendar.timeZone = tz }
        var comps = DateComponents()
        comps.year = 2000
        comps.month = 1
        comps.day = 1
        comps.hour = hours
        comps.minute = minutes
        comps.second = 0
        let date = calendar.date(from: comps) ?? Date(timeIntervalSince1970: 0)
        return df.string(from: date)
    }
}
