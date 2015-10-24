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
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentStore = urls[urls.count-1]
        
        let modelURL = NSBundle.mainBundle().URLForResource("Jotts", withExtension: "momd") as NSURL!
        let model = NSManagedObjectModel(contentsOfURL: modelURL) as NSManagedObjectModel!

        let coordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let url = documentStore.URLByAppendingPathComponent("Jotts.sqlite")

        try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        
        self.managedObjectContext.persistentStoreCoordinator = coordinator
    }
    
    // MARK: - Helper functions
    
    internal func entity(name: String) -> NSEntityDescription {
        return NSEntityDescription.entityForName(name, inManagedObjectContext: self.managedObjectContext)!
    }
    
    // MARK: - Operational functions
    
    func save() {
        do {
            try self.managedObjectContext.save()
        } catch let error as NSError {
            print(error)
            abort()
        }
    }
    
    func delete(classroom: Classroom) {
        if let schedule = classroom.schedule {
            schedule.enumerateObjectsUsingBlock({ (x, _, _) -> Void in
                
                if let object = x as? Schedule {
                    self.managedObjectContext.deleteObject(object)
                }
            })
        }
        self.managedObjectContext.deleteObject(classroom)
    }
    
    // MARK: - NSFetchRequest queries
    
    func fetch_classes() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest()
        
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
        
        let items = try self.managedObjectContext.executeFetchRequest(fetchRequest)
        
        return items as! [Classroom]
    }
    
    // MARK: - Object instantiators
    
    func newClassroom() -> Classroom {
        return Classroom(core: self)
    }
}
