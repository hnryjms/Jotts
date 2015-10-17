//
//  ObjectCore.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import Foundation
import CoreData
import ReactiveCocoa

class ObjectCore {
    let managedObjectContext: NSManagedObjectContext
    
    init() throws {
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentStore = urls[urls.count-1];
        
        let modelURL = NSBundle.mainBundle().URLForResource("Jotts", withExtension: "momd") as NSURL!;
        let model = NSManagedObjectModel(contentsOfURL: modelURL) as NSManagedObjectModel!;

        let coordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let url = documentStore.URLByAppendingPathComponent("Jotts.sqlite")

        try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        
        self.managedObjectContext.persistentStoreCoordinator = coordinator
    }
    
    func entity(name: String) -> NSEntityDescription {
        return NSEntityDescription.entityForName(name, inManagedObjectContext: self.managedObjectContext)!;
    }
    
    func classes() throws -> [Classroom] {
        let fetchRequest = NSFetchRequest()
        
        let entity = self.entity("Classroom")
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = sortDescriptors
        
        let items = try self.managedObjectContext.executeFetchRequest(fetchRequest);
        
        return items as! [Classroom]
    }
    
    func newClassroom() -> Classroom {
        return Classroom(core: self)
    }
}
