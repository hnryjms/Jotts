//
//  Classroom+Infer.swift
//  iOS
//
//  Created by Hank Brekke on 6/23/20.
//  Copyright © 2020 Hank Brekke. All rights reserved.
//

import CoreData

extension Classroom {
    static func infer(context: NSManagedObjectContext, building: Building? = nil) -> Classroom {
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

        let classroom = Classroom(context: context)
        classroom.color = color.rawValue
        classroom.schedule = schedule

        if let building = building ?? Building.infer(context: context) {
            building.objectWillChange.send()
            building.addToClassrooms(classroom)
        }

        return classroom
    }
}
