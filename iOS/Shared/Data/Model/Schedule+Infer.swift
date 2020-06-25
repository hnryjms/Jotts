//
//  Schedule+Infer.swift
//  Jotts
//
//  Created by Hank Brekke on 6/23/20.
//  Copyright © 2020 Hank Brekke. All rights reserved.
//

import CoreData

extension Schedule {
    static func infer(context: NSManagedObjectContext, classroom: Classroom) -> Schedule {
        let schedule = Schedule(context: context)

        classroom.addToSchedule(schedule)

        return schedule
    }
}
