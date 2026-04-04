//
//  Date+GeneralExtensions.swift
//
//
//  Created by Hunter Holland on 17.03.23.
//  Copyright © See Framework's LICENSE file
//
//  Extensions on `Calendar` and `Date` for UTC-based date component access
//  and common calendar utilities.
//

import Foundation

public extension Calendar {

    /// The Gregorian calendar fixed to UTC (offset 0 seconds from GMT).
    ///
    /// Use this calendar whenever you need consistent, timezone-independent
    /// component extraction (year, month, day, etc.) regardless of the
    /// device's local timezone setting.
    ///
    /// `TimeZone(secondsFromGMT: 0)` always succeeds for offset 0, so the
    /// force-unwrap here is safe.
    static let gregorianUTC: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()
}

public extension Date {

    // MARK: - Calendar arithmetic

    /// Whether the date falls in a leap year, evaluated in UTC.
    ///
    /// A year is a leap year if it is divisible by 4, except for century years,
    /// which must be divisible by 400.  For example, 2000 and 2024 are leap years
    /// while 1900 and 2023 are not.
    var isInLeapYear: Bool { (year % 100) == 0 ? (year % 400) == 0 : (year % 4) == 0 }

    // MARK: - UTC date components

    /// The year component of the date in UTC.
    ///
    /// Years in the Common Era (AD) are positive; years in the era before
    /// the Common Era (BC) are returned as negative integers.
    var year: Int {
        let components = Calendar.gregorianUTC.dateComponents([.era, .year], from: self)
        let year       = components.year ?? 0
        return (components.era ?? 1) == 1 ? year : -year
    }

    /// The month component of the date in UTC (1 = January … 12 = December).
    var month: Int { Calendar.gregorianUTC.component(.month, from: self) }

    /// The day-of-month component of the date in UTC (1–31).
    var day: Int { Calendar.gregorianUTC.component(.day, from: self) }

    /// The hour component of the date in UTC (0–23).
    var hour: Int { Calendar.gregorianUTC.component(.hour, from: self) }

    /// The minute component of the date in UTC (0–59).
    var minute: Int { Calendar.gregorianUTC.component(.minute, from: self) }

    /// The second component of the date in UTC (0–59).
    var second: Int { Calendar.gregorianUTC.component(.second, from: self) }

    /// The nanosecond component of the date in UTC.
    var nanosecond: Int { Calendar.gregorianUTC.component(.nanosecond, from: self) }

    /// The time of day expressed as a fractional number of hours in UTC.
    ///
    /// For example, 13:30:00 returns `13.5` and midnight returns `0.0`.
    ///
    /// The value is computed as:
    /// `hour + minute/60 + second/3600 + nanosecond/3_600_000_000_000`
    var fractionalHour: Double {
        Double(hour)
            + Double(minute) / 60
            + Double(second) / 3_600
            + Double(nanosecond) / 3_600_000_000_000
    }
}
