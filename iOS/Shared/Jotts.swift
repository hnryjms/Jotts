//
//  Jotts.swift
//  iOS
//
//  Created by Hank Brekke on 6/23/20.
//  Copyright © 2020 Hank Brekke. All rights reserved.
//

import SwiftUI
import CoreData


#if DEBUG
// SwiftUI Previews may mutate managed objects... so we need to use a non-persistent context.
let globalViewContext: NSManagedObjectContext = {
    let modelURL = Bundle.main.url(forResource: "Jotts", withExtension: "momd")!
    let model = NSManagedObjectModel(contentsOf: modelURL)!

    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)

    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.persistentStoreCoordinator = coordinator

    return context
}()
#else
let globalViewContext: NSManagedObjectContext = {
    let modelURL = Bundle.main.url(forResource: "Jotts", withExtension: "momd")!
    let model = NSManagedObjectModel(contentsOf: modelURL)!

    let persistentContainer = NSPersistentContainer(name: "Jotts", managedObjectModel: model)
    persistentContainer.loadPersistentStores { (description, err) in
        if let error = err {
            fatalError("Unable to load persistent stores, \(error)")
        }
    }

    return persistentContainer.viewContext
}()
#endif

@main
struct JottsApp: App {
    var body: some Scene {
        WindowGroup {
            let building = Building.infer(context: globalViewContext)

            Classrooms(building: building)
                .environment(\.managedObjectContext, globalViewContext)
                .environment(\.building, building)
        }
    }
}
