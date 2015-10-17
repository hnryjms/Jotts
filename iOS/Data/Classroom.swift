//
//  Classroom.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import Foundation
import CoreData

class Classroom: NSManagedObject {
    init(core: ObjectCore) {
        let entity = core.entity("Classroom")
        
        let fetchRequest = NSFetchRequest()
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
        let colorPath = core.managedObjectContext.countForFetchRequest(fetchRequest, error: nil) % colors.count;
        let color = colors[colorPath];
        var schedule = NSOrderedSet(objects: Schedule(core: core))
        
        do {
            let classrooms = try core.classes()
            if classrooms.count > 0 {
                let schedule_count = Int(nearbyintf(classrooms.reduce(0, combine: { (total: Float, classroom: Classroom) -> Float in
                    return total + Float(classroom.schedule!.count);
                }) / Float(classrooms.count)));
        
                // We assume the first schedule added to each classroom follows a pattern, the second
                // schedule added follows a different pattern, and so on.
                //
                // We'll take the average number of schedules per class, and predict a new schedule
                // for this new class based on the existing schedules and classes.
                var schedule_chunks: [[Schedule]] = [];
        
                for var i = 0; i < schedule_count; i++ {
                    schedule_chunks.append([]);
                }
        
                for classroom in classrooms {
                    for var i = 0; i < schedule_count; i++ {
                        if i < classroom.schedule!.count {
                            let schedule = classroom.schedule!.array[i] as! Schedule
                            schedule_chunks[i].append(schedule);
                        }
                    }
                }
        
                let set = NSMutableOrderedSet()
                for chunk in schedule_chunks {
                    set.addObject(Schedule(predictFrom: chunk, core: core))
                }
                
                schedule = set as NSOrderedSet
            }
        } catch {
            print("Failed to predict automatic schedule")
        }
        
        super.init(entity: entity, insertIntoManagedObjectContext: core.managedObjectContext)
        
        self.color = color
        self.schedule = schedule
    }
}
