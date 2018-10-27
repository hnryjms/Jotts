//
//  Assignment+CoreDataProperties.swift
//  Jotts
//
//  Created by Hank Brekke on 10/27/18.
//  Copyright © 2018 Hank Brekke. All rights reserved.
//
//

import Foundation
import CoreData

extension Assignment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Assignment> {
        return NSFetchRequest<Assignment>(entityName: "Assignment")
    }

    @NSManaged public var completed: NSNumber?
    @NSManaged public var details: String?
    @NSManaged public var dueDate: NSDate?
    @NSManaged public var title: String?
    @NSManaged public var classroom: Classroom?

}
