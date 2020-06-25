//
//  Building+Infer.swift
//  Jotts
//
//  Created by Hank Brekke on 6/23/20.
//  Copyright © 2020 Hank Brekke. All rights reserved.
//

import CoreData

extension Building {
    static func infer(context: NSManagedObjectContext) -> Building {
        do {
            let fetchRequest: NSFetchRequest<Building> = Building.fetchRequest()
            fetchRequest.returnsObjectsAsFaults = false
            let result = try context.fetch(fetchRequest)

            if result.isEmpty {
                return Building(context: context)
            } else {
                return result[0]
            }
        } catch {
            fatalError("Unable to create default Building, \(error)")
        }
    }
}
