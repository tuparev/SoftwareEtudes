//
//  Date+GeneralExtensionsTests.swift
//
//
//  Created by Ani Klekchyan on 30.03.26.
//  Copyright © See Framework's LICENSE file
//

import Testing
import Foundation
@testable import SoftwareEtudesUtilities

// MARK: - Helpers

/// Builds a UTC `Date` from literal components.
private func utcDate(year: Int, month: Int, day: Int,
                     hour: Int = 0, minute: Int = 0, second: Int = 0,
                     nanosecond: Int = 0) -> Date {
    var c             = DateComponents()
    c.year            = year
    c.month           = month
    c.day             = day
    c.hour            = hour
    c.minute          = minute
    c.second          = second
    c.nanosecond      = nanosecond
    return Calendar.gregorianUTC.date(from: c)!
}

// MARK: - Test suites

@Suite("Date+GeneralExtensions")
struct DateGeneralExtensionsTests {

    // MARK: - Calendar.gregorianUTC

    @Suite("Calendar.gregorianUTC")
    struct GregorianUTC {

        @Test("identifier is Gregorian")
        func identifier() {
            #expect(Calendar.gregorianUTC.identifier == .gregorian)
        }

        @Test("timezone is UTC (offset 0)")
        func timezone() {
            #expect(Calendar.gregorianUTC.timeZone.secondsFromGMT() == 0)
        }
    }

    // MARK: - isInLeapYear

    @Suite("isInLeapYear")
    struct IsInLeapYear {

        @Test("divisible by 4 but not 100 is a leap year")
        func divisibleBy4() {
            #expect(utcDate(year: 2024, month: 1, day: 1).isInLeapYear)
            #expect(utcDate(year: 2020, month: 6, day: 15).isInLeapYear)
        }

        @Test("century year divisible by 400 is a leap year")
        func centuryDivisibleBy400() {
            #expect(utcDate(year: 2000, month: 3, day: 1).isInLeapYear)
        }

        @Test("century year not divisible by 400 is not a leap year")
        func centuryNotDivisibleBy400() {
            #expect(!utcDate(year: 1900, month: 1, day: 1).isInLeapYear)
            #expect(!utcDate(year: 1800, month: 1, day: 1).isInLeapYear)
        }

        @Test("non-leap years return false")
        func nonLeapYear() {
            #expect(!utcDate(year: 2023, month: 7, day: 4).isInLeapYear)
            #expect(!utcDate(year: 2019, month: 1, day: 1).isInLeapYear)
        }
    }

    // MARK: - UTC date components

    @Suite("UTC date components")
    struct UTCComponents {

        // Fixed reference: 2023-11-05 at 13:45:30 UTC
        private let reference = utcDate(year: 2023, month: 11, day: 5,
                                        hour: 13, minute: 45, second: 30)

        @Test("year returns correct UTC year")
        func year() {
            #expect(reference.year == 2023)
        }

        @Test("month returns correct UTC month")
        func month() {
            #expect(reference.month == 11)
        }

        @Test("day returns correct UTC day")
        func day() {
            #expect(reference.day == 5)
        }

        @Test("hour returns correct UTC hour")
        func hour() {
            #expect(reference.hour == 13)
        }

        @Test("minute returns correct UTC minute")
        func minute() {
            #expect(reference.minute == 45)
        }

        @Test("second returns correct UTC second")
        func second() {
            #expect(reference.second == 30)
        }

        @Test("nanosecond returns correct UTC nanosecond")
        func nanosecond() {
            let date = utcDate(year: 2023, month: 1, day: 1,
                               hour: 0, minute: 0, second: 0, nanosecond: 123_000_000)
            // Date stores time as a Double (seconds), so nanosecond round-trips
            // may drift by a few nanoseconds due to floating-point precision.
            #expect(abs(date.nanosecond - 123_000_000) < 1_000)
        }

        @Test("year 1 (AD epoch boundary) is positive")
        func yearADEpoch() {
            #expect(utcDate(year: 1, month: 1, day: 1).year == 1)
        }
    }

    // MARK: - fractionalHour

    @Suite("fractionalHour")
    struct FractionalHour {

        @Test("midnight returns 0.0")
        func midnight() {
            let date = utcDate(year: 2023, month: 1, day: 1,
                               hour: 0, minute: 0, second: 0)
            #expect(date.fractionalHour == 0.0)
        }

        @Test("13:30:00 returns 13.5")
        func halfPastOne() {
            let date = utcDate(year: 2023, month: 1, day: 1,
                               hour: 13, minute: 30, second: 0)
            #expect(date.fractionalHour == 13.5)
        }

        @Test("00:01:00 returns 1/60")
        func oneMinute() {
            let date = utcDate(year: 2023, month: 1, day: 1,
                               hour: 0, minute: 1, second: 0)
            #expect(abs(date.fractionalHour - (1.0 / 60.0)) < 1e-9)
        }

        @Test("23:59:59 is less than 24.0")
        func almostMidnight() {
            let date = utcDate(year: 2023, month: 1, day: 1,
                               hour: 23, minute: 59, second: 59)
            #expect(date.fractionalHour < 24.0)
            #expect(date.fractionalHour > 23.0)
        }

        @Test("12:00:00 noon returns 12.0")
        func noon() {
            let date = utcDate(year: 2023, month: 6, day: 21,
                               hour: 12, minute: 0, second: 0)
            #expect(date.fractionalHour == 12.0)
        }
    }
}
