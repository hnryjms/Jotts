//
//  Schedule+CoreDataProperties.swift
//  Jotts
//
//  Created by Hank Brekke on 10/27/18.
//  Copyright © 2018 Hank Brekke. All rights reserved.
//
//

import Foundation
import CoreData

extension Schedule {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Schedule> {
        return NSFetchRequest<Schedule>(entityName: "Schedule")
    }

    @NSManaged public var activeDays: NSNumber?
    @NSManaged public var endDate: NSDate?
    @NSManaged public var excludedDays: NSNumber?
    @NSManaged public var frequency: NSNumber?
    @NSManaged public var length: NSNumber?
    @NSManaged public var nextDate: NSDate?
    @NSManaged public var startDate: NSDate?
    @NSManaged public var startTime: NSNumber?
    @NSManaged public var classroom: Classroom?

}
