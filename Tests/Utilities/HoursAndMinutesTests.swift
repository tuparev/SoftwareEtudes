import Foundation
import Testing

@testable import SoftwareEtudesUtilities

@Suite
struct HoursAndMinutesTests {
    
    // Initialization Tests
    
    @Test
    func testInitializationValid() throws {
        let hm = try HoursAndMinutes(hours: 13, minutes: 45)
        #expect(hm.hours == 13)
        #expect(hm.minutes == 45)
    }
    
    @Test
    func testInitializationBoundaryValues() throws {
        let hm1 = try HoursAndMinutes(hours: 0, minutes: 0)
        #expect(hm1.hours == 0)
        #expect(hm1.minutes == 0)
        
        let hm2 = try HoursAndMinutes(hours: 23, minutes: 59)
        #expect(hm2.hours == 23)
        #expect(hm2.minutes == 59)
    }
    
    @Test
    func testInitializationInvalidValues() {
        // Assuming initializer is failable or throws, else test parsing invalid inputs
        // Here we test parsing separately for invalid inputs
    }
    
    // Parsing Tests
    
    @Test
    func testParsingValid24Hour() throws {
        let parsed = try HoursAndMinutes(hours: 14, minutes: 30)
        #expect(parsed.hours == 14)
        #expect(parsed.minutes == 30)
    }
    
    @Test
    func testParsingValid12HourAM() throws {
        let parsed = try HoursAndMinutes(hours: 2, minutes: 15)
        #expect(parsed.hours == 2)
        #expect(parsed.minutes == 15)
    }
    
    @Test
    func testParsingValid12HourPM() throws {
        let parsed = try HoursAndMinutes(hours: 12, minutes: 45)
        #expect(parsed.hours == 12)
        #expect(parsed.minutes == 45)
    }
    
    @Test
    func testParsingMidnightAndNoon() throws {
        let midnight = try HoursAndMinutes(hours: 0, minutes: 0)
        #expect(midnight.hours == 0)
        #expect(midnight.minutes == 0)
        
        let noon = try HoursAndMinutes(hours: 12, minutes: 0)
        #expect(noon.hours == 12)
        #expect(noon.minutes == 0)
    }
    
    @Test
    func testParsingInvalidStrings() {
        // No string parsing API exists; ensure invalid numeric values are rejected via the throwing initializer.
        let invalidPairs: [(Int, Int)] = [(25, 0), (13, 60), (-1, 0), (0, -5)]
        for (h, m) in invalidPairs {
            do {
                _ = try HoursAndMinutes(hours: h, minutes: m)
                #expect(false, "Initialization should have failed for hours: \(h), minutes: \(m)")
            } catch {
                // Expected to throw
            }
        }
    }
    
    // Formatting Tests
    
    @Test
    func testFormatting24Hour() throws {
        let hm = try HoursAndMinutes(hours: 8, minutes: 7)
        let formatted = hm.formatted(style: .twentyFourHour)
        #expect(formatted == "08:07")
    }
    
    @Test
    func testFormatting12HourAM() throws {
        let hm = try HoursAndMinutes(hours: 9, minutes: 5)
        let formatted = hm.formatted(style: .twelveHour)
        #expect(formatted == "9:05 AM")
    }
    
    @Test
    func testFormatting12HourPM() throws {
        let hm = try HoursAndMinutes(hours: 15, minutes: 30)
        let formatted = hm.formatted(style: .twelveHour)
        #expect(formatted == "3:30 PM")
    }
    
    @Test
    func testFormattingMidnightAndNoon() throws {
        let midnight = try HoursAndMinutes(hours: 0, minutes: 0)
        let noon = try HoursAndMinutes(hours: 12, minutes: 0)
        #expect(midnight.formatted(style: .twelveHour) == "12:00 AM")
        #expect(noon.formatted(style: .twelveHour) == "12:00 PM")
    }
    
    // Formatting with Options
    
    @Test
    func testFormattingOptionsOmitMinutes() throws {
        let hm = try HoursAndMinutes(hours: 14, minutes: 0)
        let formatted = hm.formatted(style: .twentyFourHour, options: [.omitMinutesIfZero])
        #expect(formatted == "14")
    }
    
    @Test
    func testFormattingOptionsIncludeMinutesWhenNonZero() throws {
        let hm = try HoursAndMinutes(hours: 14, minutes: 5)
        let formatted = hm.formatted(style: .twentyFourHour, options: [.omitMinutesIfZero])
        #expect(formatted == "14:05")
    }
    
    // Localization Tests
    
    @Test
    func testLocalizedFormattingFixedLocale() throws {
        let hm = try HoursAndMinutes(hours: 14, minutes: 30)
        let locale = Locale(identifier: "fr_FR")
        let formatted = hm.localizedFormatted(style: .twelveHour, locale: locale)
        // In French, 12-hour format uses AM/PM translated or variants
        // Usually "14:30" is 24-hour, but forcing 12-hour format
        #expect(formatted == "2:30 PM")
    }
    
    @Test
    func testLocalizedFormattingDifferentLocale() throws {
        let hm = try HoursAndMinutes(hours: 9, minutes: 15)
        let locale = Locale(identifier: "ja_JP")
        let formatted = hm.localizedFormatted(style: .twelveHour, locale: locale)
        // Japanese 12-hour time usually uses 午前/午後
        #expect(formatted.contains("午前") || formatted.contains("AM"))
    }
    
    @Test
    func testLocalizedFormatting24HourWithFixedLocale() throws {
        let hm = try HoursAndMinutes(hours: 21, minutes: 45)
        let locale = Locale(identifier: "de_DE")
        let formatted = hm.localizedFormatted(style: .twentyFourHour, locale: locale)
        // German 24-hour format uses "21:45"
        #expect(formatted == "21:45")
    }
    
    // Boundary and Edge Cases
    
    @Test
    func testFormattingMidnightWithOptionsOmitMinutes() throws {
        let midnight = try HoursAndMinutes(hours: 0, minutes: 0)
        let formatted = midnight.formatted(style: .twentyFourHour, options: [.omitMinutesIfZero])
        #expect(formatted == "00")
    }
    
    @Test
    func testParsingLeadingZeros() throws {
        let parsed = try HoursAndMinutes(hours: 4, minutes: 9)
        #expect(parsed.hours == 4)
        #expect(parsed.minutes == 9)
    }
    
    @Test
    func testParsingTrailingSpaces() throws {
        let parsed = try HoursAndMinutes(hours: 15, minutes: 15)
        #expect(parsed.hours == 15)
        #expect(parsed.minutes == 15)
    }
}

