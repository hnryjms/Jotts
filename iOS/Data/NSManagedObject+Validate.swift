//
//  NSManagedObject+Validate.swift
//  Jotts
//
//  Created by Hank Brekke on 10/22/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import CoreData

extension NSManagedObject {
    /**
        Validates the object for the action being performed on it in the
        current managed object context.
     */
    func validate() throws {
        if self.isInserted {
            return try self.validateForInsert()
        } else if self.isUpdated {
            return try self.validateForUpdate()
        } else if self.isDeleted {
            return try self.validateForDelete()
        }
    }
}
