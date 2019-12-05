//
// Created by Hank Brekke on 5/7/17.
// Copyright (c) 2017 Hank Brekke. All rights reserved.
//

import Foundation

extension Date {
    public init(midnightFromDate date: Date) {
        self.init(timeInterval: 0, since: Calendar.current.startOfDay(for: date))
    }

    public init(timeIntervalSinceMidnight timeInterval: TimeInterval, from: Date = Date()) {
        let midnight = Date(midnightFromDate: from)
        self.init(timeInterval: timeInterval, since: midnight)
    }

    public var timeIntervalSinceMidnight: TimeInterval {
        get {
            let midnight = Date(midnightFromDate: self)
            return self.timeIntervalSince(midnight)
        }
    }
}
