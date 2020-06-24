//
//  ScheduleObserver.swift
//  Jotts
//
//  Created by Hank Brekke on 12/1/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import Foundation
import Combine
import CoreData

class DailyScheduleObservable: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var schedule: DailySchedule

    private var controllers: [NSFetchedResultsController<NSFetchRequestResult>]
    private var scheduleSettings: AnyCancellable?

    init(schedule: DailySchedule) {
        self.schedule = schedule

        let fetchRequests: [NSFetchRequest<NSFetchRequestResult>] = [
            Schedule.fetchRequest(),
            Session.fetchRequest(),
            Classroom.fetchRequest()
        ]

        self.controllers = fetchRequests.map({ fetchRequest -> NSFetchedResultsController<NSFetchRequestResult> in
            fetchRequest.sortDescriptors = []

            let controller = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: globalPersistentContainer.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            return controller
        })

        super.init()

        self.scheduleSettings = schedule.building.objectWillChange.sink { _ in
            DispatchQueue.main.async {
                self.schedule = try! globalBuilding.schedule()
            }
        }

        self.controllers.forEach { controller in
            controller.delegate = self

            try!controller.performFetch()
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller.fetchRequest.entity == Schedule.entity() ||
            controller.fetchRequest.entity == Session.entity() {
            self.schedule = try! globalBuilding.schedule()
        } else {
            self.objectWillChange.send()
        }
    }
}
