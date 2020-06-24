//
//  Jotts.swift
//  iOS
//
//  Created by Hank Brekke on 6/23/20.
//  Copyright © 2020 Hank Brekke. All rights reserved.
//

import SwiftUI
import CoreData

let globalPersistentContainer: NSPersistentContainer = {
    let modelURL = Bundle.main.url(forResource: "Jotts", withExtension: "momd")!
    let model = NSManagedObjectModel(contentsOf: modelURL)!

    let persistentContainer = NSPersistentContainer(name: "Jotts", managedObjectModel: model)
    persistentContainer.loadPersistentStores { (description, err) in
        if let error = err {
            fatalError("Unable to load persistent stores, \(error)")
        }
    }

    return persistentContainer
}()

let globalBuilding: Building = {
    do {
        let viewContext = globalPersistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Building> = Building.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        let result = try viewContext.fetch(fetchRequest)

        if result.isEmpty {
            return Building(context: viewContext)
        } else {
            return result[0]
        }
    } catch {
        fatalError("Unable to create default Building, \(error)")
    }
}()

@main
struct Jotts: App {
    var body: some Scene {
        WindowGroup {
            let schedule = try! globalBuilding.schedule()

            Classrooms(
                schedule: DailyScheduleObservable(schedule: schedule)
            )
            .environment(\.managedObjectContext, globalPersistentContainer.viewContext)
        }
    }
}
