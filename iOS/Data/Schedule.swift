//
//  Schedule.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import Foundation
import CoreData
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class Schedule: NSManagedObject {
    convenience init(core: ObjectCore) {
        let entity = core.entity("Schedule")
        self.init(entity: entity, insertInto: core.managedObjectContext)

        let defaultDays: [Weekdays] = [.monday, .tuesday, .wednesday, .thursday, .friday]
        self.activeDays = NSNumber(value: defaultDays.toBitwise())

        self.startTime = 27000
    }
    convenience init(predictFrom schedules: [Schedule], core: ObjectCore)  {
        self.init(core: core)
    }

    // MARK: - Observable properties

    var rac_startTime: SignalProducer<TimeInterval?, NoError> {
        get {
            return DynamicProperty<NSNumber?>(object: self, keyPath: #keyPath(startTime)).producer
                .map {
                    startTime in

                    return startTime??.doubleValue
                }
        }
    }

    var rac_activeDays: SignalProducer<[Weekdays], NoError> {
        get {
            return DynamicProperty<NSNumber?>(object: self, keyPath: #keyPath(activeDays)).producer
                .map { activeDays in
                    return activeDays!!.uintValue.toWeekdays()
                }
        }
    }

    // Mark: - Calculated properties

    var rac_details: SignalProducer<String, NoError> {
        get {
            let signal = SignalProducer.combineLatest(self.rac_startTime, self.rac_activeDays)
                .map { (startTime, activeDays) -> String in
                    guard startTime != nil else {
                        return "Unknown"
                    }

                    let daysOfWeek = activeDays
                    let startTime = Date(timeIntervalSinceMidnight: startTime!)

                    let timeFormat = DateFormatter()
                    timeFormat.dateStyle = .none
                    timeFormat.timeStyle = .short


                    let localizedFormat = NSLocalizedString("Schedule.%@At%@", comment: "[Days-of-week] at [Time-of-day]")
                    return String(format: localizedFormat, daysOfWeek.toLocalizedString(), timeFormat.string(from: startTime))
                }

            return signal
        }
    }
}
