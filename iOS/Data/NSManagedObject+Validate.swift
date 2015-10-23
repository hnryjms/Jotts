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
        if self.inserted {
            return try self.validateForInsert()
        } else if self.updated {
            return try self.validateForUpdate()
        } else if self.deleted {
            return try self.validateForDelete()
        }
        
        throw NSError(domain: "io.hnryjms.Jotts", code: 1, userInfo: nil)
    }
}
