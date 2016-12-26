//
//  Assignment+CoreDataProperties.swift
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

extension Assignment {

    @NSManaged var completed: NSNumber?
    @NSManaged var details: String?
    @NSManaged var dueDate: Date?
    @NSManaged var title: String?
    @NSManaged var classroom: Classroom?

}
