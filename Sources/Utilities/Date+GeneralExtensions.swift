//
//  Date+GeneralExtensions.swift
//  
//
//  Created by Hunter Holland on 17.03.23.
//  Copyright © See Framework's LICENSE file
//

import Foundation

public extension Calendar {
    /// The Gregorian calendar, with times in UTC.
    static let gregorianUTC: Calendar = {
        var calendar = Calendar(identifier: .gregorian)

        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        return calendar
    }()
}

public extension Date {

    /// A boolean indicating whether or not the date occurs in a leap year.
    var isInLeapYear : Bool { (year % 100) == 0 ? (year % 400) == 0 : (year % 4) == 0 }

    // MARK: - Date Components
    /// The year component of the date, in UTC.
    var year: Int {
        let era  = Calendar.gregorianUTC.component(.era, from: self)
        let year = Calendar.gregorianUTC.component(.year, from: self)

        return era == 1 ? year : -year
    }

    /// The month component of the date, in UTC.
    var month: Int { Calendar.gregorianUTC.component(.month, from: self) }

    /// The day component of the date, in UTC.
    var day: Int { Calendar.gregorianUTC.component(.day, from: self) }

    /// The hour component of the date, in UTC.
    var hour: Int { Calendar.gregorianUTC.component(.hour, from: self) }

    /// The minute component of the date, in UTC.
    var minute: Int { Calendar.gregorianUTC.component(.minute, from: self) }

    /// The second component of the date, in UTC.
    var second: Int { Calendar.gregorianUTC.component(.second, from: self) }

    /// The nanosecond component of the date, in UTC.
    var nanosecond: Int { Calendar.gregorianUTC.component(.nanosecond, from: self) }

    /// The time of day expressed as a decimal number of hours.
    var fractionalHour: Double { Double(hour) + Double(minute)/60 + Double(second)/3600 + Double(nanosecond)/1e9/3600 }

}
