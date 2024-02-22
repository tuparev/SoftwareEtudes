//
//  TimeIntervalUtilities.swift
//  
//
//  Created by Georg Tuparev on 28/03/2022.
//  Copyright © See Framework's LICENSE file
//

import Foundation

public struct SimpleTimeInterval: Codable {
    public var seconds: Int  // 0-59
    public var minutes: Int  // 0-59
    public var hours : Int   // 0-23
    public var days: Int     // 0-♾️

    init(seconds: Int) {
        var reminder = seconds

        self.days    = reminder / _secondInDay
        reminder     = reminder - (days * _secondInDay)

        self.hours   = reminder / _secondsInHour
        reminder     = reminder - (hours * _secondsInHour)

        self.minutes = reminder / _secondsInMinute
        reminder     = reminder - (minutes * _secondsInMinute)

        self.seconds = reminder
    }
}

public extension Int {
    init?(time: String) {
        guard time.count > 1 else { return nil }

        var timeString = time
        let timeUnit   = String(timeString.removeLast())
        let currentSet = CharacterSet(charactersIn: timeUnit)

        if _possibleTimeUnits.isSuperset(of: currentSet) {
            guard let value = Int(timeString) else { return nil }

            switch timeUnit {
                case "s": self = value
                case "m": self = value * _secondsInMinute
                case "h": self = value * _secondsInHour
                case "d": self = value * _secondInDay
                default: return nil
            }
        }
        else { return nil }
    }
    //TODO: Implement `time` so that string 2d11h5m3s is VALID!

    var s: Int { self }
    var m: Int { self / _secondsInMinute }
    var h: Int { self / _secondsInHour }
    var d: Int { self / _secondInDay}

    func timeInterval() -> SimpleTimeInterval { SimpleTimeInterval(seconds: self) }
}

fileprivate let _possibleTimeUnits = CharacterSet(charactersIn: "smhd")

fileprivate let _secondsInMinute = 60
fileprivate let _secondsInHour   = _secondsInMinute * 60
fileprivate let _secondInDay     = _secondsInHour * 24
