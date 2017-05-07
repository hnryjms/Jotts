//
//  Classroom.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import Foundation
import CoreData
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class Classroom: NSManagedObject {
    convenience init(core: ObjectCore) {
        let entity = core.entity("Classroom")
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        
        // Classroom defaults
        let colors = [
            "ff8100", // orange
            "ff0080", // pink
            "00b60e", // green
            "e72b00", // red
            "83f218", // light green
            "c66bff", // light purple
            "00b190", // teal
            "0e4dff", // dark blue
            "7a40a3", // purple
            "996600"  // brown
        ];
        let color: String;
        do {
            let colorPath = try core.managedObjectContext.count(for: fetchRequest) % colors.count;
            color = colors[colorPath];
        } catch {
            color = colors[0];
        }

        let schedule: NSOrderedSet
        do {
            let classrooms = try core.classes()
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
                            let schedule = classroom.schedule!.array[i] as! Schedule
                            schedule_chunks[i].append(schedule);
                        }
                    }
                }
        
                let set = NSMutableOrderedSet()
                for chunk in schedule_chunks {
                    set.add(Schedule(predictFrom: chunk, core: core))
                }
                
                schedule = set as NSOrderedSet
            } else {
                schedule = NSOrderedSet(objects: Schedule(core: core))
            }
        } catch {
            print("Failed to predict automatic schedule")
            schedule = NSOrderedSet(objects: Schedule(core: core))
        }
        
        self.init(entity: entity, insertInto: core.managedObjectContext)
        
        self.color = color
        self.schedule = schedule
    }
    
    // MARK: - Observable properties
    
    var rac_title: SignalProducer<String?, NoError> {
        get {
            return DynamicProperty<String>(object: self, keyPath: #keyPath(title)).producer
        }
    }
    var rac_instructor: SignalProducer<String?, NoError> {
        get {
            return DynamicProperty<String>(object: self, keyPath: #keyPath(instructor)).producer
        }
    }
    var rac_room: SignalProducer<String?, NoError> {
        get {
            return DynamicProperty<String>(object: self, keyPath: "room").producer
        }
    }
    var rac_color: SignalProducer<String?, NoError> {
        get {
            return DynamicProperty<String>(object: self, keyPath: #keyPath(color)).producer
        }
    }
    
    // MARK: - Calculated properties
    
    var rac_details: SignalProducer<String, NoError> {
        get {
            let signal = SignalProducer.combineLatest(self.rac_room, self.rac_instructor)
                .map { (room, instructor) -> String in
                    var details: [String] = []
                    if let roomValue = room {
                        if Int(roomValue) != nil {
                            let roomValueString = String(format: NSLocalizedString("Classroom.room_%@", comment: "Room Number"), roomValue)
                            details.append(roomValueString)
                        } else {
                            details.append(roomValue)
                        }
                    }
                    if let instructorValue = instructor {
                        details.append(instructorValue)
                    }
                    
                    return details.joined(separator: " - ")
                }
            
            return signal
        }
    }
}
