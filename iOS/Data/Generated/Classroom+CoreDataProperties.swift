//
//  Classroom+CoreDataProperties.swift
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

extension Classroom {

    @NSManaged var color: String?
    @NSManaged var instructor: String?
    @NSManaged var networkID: String?
    @NSManaged var room: String?
    @NSManaged var title: String?
    @NSManaged var assignments: NSSet?
    @NSManaged var decks: NSSet?
    @NSManaged var schedule: NSOrderedSet?
    @NSManaged var sessions: NSSet?

}
