//
//  ObjectCore.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import Foundation
import CoreData

class ObjectCore {
    let managedObjectContext: NSManagedObjectContext
    
    init() throws {
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentStore = urls[urls.count-1]
        
        let modelURL = Bundle.main.url(forResource: "Jotts", withExtension: "momd") as URL!
        let model = NSManagedObjectModel(contentsOf: modelURL!) as NSManagedObjectModel!

        let coordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model!)
        let url = documentStore.appendingPathComponent("Jotts.sqlite")

        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        
        self.managedObjectContext.persistentStoreCoordinator = coordinator
    }
    
    // MARK: - Helper functions
    
    internal func entity(_ name: String) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: name, in: self.managedObjectContext)!
    }
    
    // MARK: - Operational functions
    
    func save() {
        do {
            try self.managedObjectContext.save()
        } catch let error as NSError {
            print("Tried to save invalid data store \(error)")
        }
    }
    
    func delete(_ classroom: Classroom) {
        if let schedule = classroom.schedule {
            schedule.enumerateObjects({ (x, _, _) -> Void in
                
                if let object = x as? Schedule {
                    self.managedObjectContext.delete(object)
                }
            })
        }
        self.managedObjectContext.delete(classroom)
    }
    
    // MARK: - NSFetchRequest queries
    
    func fetch_classes() -> NSFetchRequest<Classroom> {
        let fetchRequest = NSFetchRequest<Classroom>()
        
        let entity = self.entity("Classroom")
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = sortDescriptors
        
        return fetchRequest
    }
    
    // MARK: - Request queriers
    
    func classes() throws -> [Classroom] {
        let fetchRequest = self.fetch_classes()
        
        let items = try self.managedObjectContext.fetch(fetchRequest)
        
        return items
    }
    
    // MARK: - Object instantiators
    
    func newClassroom() -> Classroom {
        return Classroom(core: self)
    }
}
