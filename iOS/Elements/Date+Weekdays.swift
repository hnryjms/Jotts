//
// Created by Hank Brekke on 5/7/17.
// Copyright (c) 2017 Hank Brekke. All rights reserved.
//

import Foundation

enum Weekdays: UInt {
    case monday = 0b1
    case tuesday = 0b10
    case wednesday = 0b100
    case thursday = 0b1000
    case friday = 0b10000
    case saturday = 0b100000
    case sunday = 0b1000000
}

extension UInt {
    func toWeekdays() -> [Weekdays] {
        var weekdays: [Weekdays] = [];
        if self & Weekdays.monday.rawValue != 0 {
            weekdays += [.monday]
        }
        if self & Weekdays.tuesday.rawValue != 0 {
            weekdays += [.tuesday]
        }
        if self & Weekdays.wednesday.rawValue != 0 {
            weekdays += [.wednesday]
        }
        if self & Weekdays.thursday.rawValue != 0 {
            weekdays += [.thursday]
        }
        if self & Weekdays.friday.rawValue != 0 {
            weekdays += [.friday]
        }
        if self & Weekdays.saturday.rawValue != 0 {
            weekdays += [.saturday]
        }
        if self & Weekdays.sunday.rawValue != 0 {
            weekdays += [.sunday]
        }

        return weekdays;
    }
}

extension Array where Element == Weekdays {
    func toBitwise() -> UInt {
        var bitwise: UInt = 0
        if self.contains(.monday) {
            bitwise |= Weekdays.monday.rawValue
        }
        if self.contains(.tuesday) {
            bitwise |= Weekdays.tuesday.rawValue
        }
        if self.contains(.wednesday) {
            bitwise |= Weekdays.wednesday.rawValue
        }
        if self.contains(.thursday) {
            bitwise |= Weekdays.thursday.rawValue
        }
        if self.contains(.friday) {
            bitwise |= Weekdays.friday.rawValue
        }
        if self.contains(.saturday) {
            bitwise |= Weekdays.saturday.rawValue
        }
        if self.contains(.sunday) {
            bitwise |= Weekdays.sunday.rawValue
        }
        return bitwise
    }

    func toLocalizedString() -> String {
        let bitwise = self.toBitwise()

        let localizedKey = "Weekday_\(bitwise)"
        let localizedValue = NSLocalizedString(localizedKey, comment: "Localized Weekday Set")
        if localizedValue != localizedKey {
            return localizedValue
        }

        return self.map { day in
            let localizedKey = "Weekday_\(day.rawValue)_short"
            return NSLocalizedString(localizedKey, comment: "Localized Weekday Set")
        }.joined(separator: ", ")
    }
}

extension Date {
    init(midnightFromDate date: Date) {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date);
        let midnight = Calendar.current.date(from: components)!
        self.init(timeInterval: 0, since: midnight)
    }

    init(timeIntervalSinceMidnight timeInterval: TimeInterval, from: Date = Date()) {
        let midnight = Date(midnightFromDate: from)
        self.init(timeInterval: timeInterval, since: midnight)
    }

    func toLocalizedWeekdayString() -> String {
        let dateComponents = Calendar(identifier: .iso8601).dateComponents([.weekday], from: self)
        let bitwise: UInt = 1 << dateComponents.weekday!

        let localizedKey = "Weekday_\(bitwise)"
        return NSLocalizedString(localizedKey, comment: "Localized Weekday Set")
    }
}
