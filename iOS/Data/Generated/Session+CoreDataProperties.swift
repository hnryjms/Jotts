//
//  Session+CoreDataProperties.swift
//  Jotts
//
//  Created by Hank Brekke on 10/27/18.
//  Copyright © 2018 Hank Brekke. All rights reserved.
//
//

import Foundation
import CoreData

extension Session {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Session> {
        return NSFetchRequest<Session>(entityName: "Session")
    }

    @NSManaged public var length: NSNumber?
    @NSManaged public var startDate: NSDate?
    @NSManaged public var classroom: Classroom?

}
