//
//  Schedule+CoreDataProperties.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Schedule {

    @NSManaged var activeDays: NSNumber?
    @NSManaged var endDate: Date?
    @NSManaged var excludedDays: NSNumber?
    @NSManaged var frequency: NSNumber?
    @NSManaged var length: NSNumber?
    @NSManaged var nextDate: Date?
    @NSManaged var startDate: Date?
    @NSManaged var startTime: NSNumber?
    @NSManaged var classroom: Classroom?

}
