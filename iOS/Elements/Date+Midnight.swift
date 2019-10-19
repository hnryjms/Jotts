//
// Created by Hank Brekke on 5/7/17.
// Copyright (c) 2017 Hank Brekke. All rights reserved.
//

import Foundation

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

    var timeIntervalSinceMidnight: TimeInterval {
        get {
            let midnight = Date(midnightFromDate: self)
            return self.timeIntervalSince(midnight)
        }
    }
}
