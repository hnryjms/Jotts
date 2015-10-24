//
//  Schedule.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import Foundation
import CoreData

class Schedule: NSManagedObject {
    convenience init(core: ObjectCore) {
        let entity = core.entity("Schedule")
        self.init(entity: entity, insertIntoManagedObjectContext: core.managedObjectContext)
    }
    convenience init(predictFrom schedules: [Schedule], core: ObjectCore)  {
        self.init(core: core)
    }
}
