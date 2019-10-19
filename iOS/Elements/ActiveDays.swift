//
//  ActiveDays.swift
//  Jotts
//
//  Created by Hank Brekke on 10/19/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import Foundation

extension Int64 {
    func isSelected(day index: Int16) -> Bool {
        return self & Int64(truncating: pow(2, Int(index)) as NSDecimalNumber) != 0
    }

    func count() -> Int {
        var shiftSelf = self
        var count = 0
        while shiftSelf != 0 {
            count += 1
            shiftSelf >>= 1
        }
        return count
    }

    mutating func select(day index: Int16) {
        self = self | Int64(truncating: pow(2, Int(index)) as NSDecimalNumber)
    }

    mutating func deselect(day index: Int16) {
        self = self ^ Int64(truncating: pow(2, Int(index)) as NSDecimalNumber)
    }
}
