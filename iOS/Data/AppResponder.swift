//
//  AppResponder.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import UIKit
import CoreData

@objc protocol AppActions {
    func addClassroom()
    func addAssignment()

    func save()
}

class AppResponder: UIResponder, AppActions {
    var persistentContainer: NSPersistentContainer {
        get { AppDelegate.sharedDelegate().persistentContainer }
    }
    var building: Building {
        get { AppDelegate.sharedDelegate().building }
    }

    func addClassroom() {
        let context = self.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Classroom>(entityName: Classroom.entity().name!)

        // Classroom defaults
        let color: ColorHex;
        do {
            let colorPath = try context.count(for: fetchRequest) % ColorHex.sorted.count;
            color = ColorHex.sorted[colorPath];
        } catch {
            color = ColorHex.sorted[0];
        }

        let schedule: NSSet
        do {
            let classrooms = try context.fetch(fetchRequest)
            if classrooms.count > 0 {
                let schedule_count = classrooms.reduce(0, { (total: Int, classroom: Classroom) -> Int in
                    return total + classroom.schedule!.count
                }) / classrooms.count;

                // We assume the first schedule added to each classroom follows a pattern, the second
                // schedule added follows a different pattern, and so on.
                //
                // We'll take the average number of schedules per class, and predict a new schedule
                // for this new class based on the existing schedules and classes.
                var schedule_chunks: [[Schedule]] = [];

                for _ in 0 ..< schedule_count {
                    schedule_chunks.append([]);
                }

                for classroom in classrooms {
                    for i in 0 ..< schedule_count {
                        if i < classroom.schedule!.count {
                            let schedule = classroom.schedule!.allObjects[i] as! Schedule
                            schedule_chunks[i].append(schedule);
                        }
                    }
                }

                let set = NSMutableSet()
                for chunk in schedule_chunks {
                    let schedule = Schedule(context: context)
                    // TODO: add prediction
                    set.add(schedule)
                }

                schedule = set as NSSet
            } else {
                schedule = NSSet(objects: Schedule(context: context))
            }
        } catch {
            print("Failed to predict automatic schedule")
            schedule = NSSet(objects: Schedule(context: context))
        }

        let classroom = Classroom(context: self.persistentContainer.viewContext)
        classroom.color = color.rawValue
        classroom.schedule = schedule

        self.building.objectWillChange.send()
        self.building.addToClassrooms(classroom)
    }

    func addAssignment() {
        print("add assignment")
    }

    func save() {
        do {
            try self.persistentContainer.viewContext.save()
        } catch {
            print("Unable to save \(error)")
        }
    }
}
