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

    func count(rotationSize: Int16) -> Int {
        return (0...rotationSize).reduce(0) { (count, day) -> Int in
            return count + (self.isSelected(day: day) ? 1 : 0)
        }
    }

    mutating func select(day index: Int16) {
        self = self | Int64(truncating: pow(2, Int(index)) as NSDecimalNumber)
    }

    mutating func deselect(day index: Int16) {
        self = self ^ Int64(truncating: pow(2, Int(index)) as NSDecimalNumber)
    }
}
