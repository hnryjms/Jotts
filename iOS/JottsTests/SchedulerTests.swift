//
//  SchedulerTests.swift
//  JottsTests
//
//  Created by Hank Brekke on 11/24/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import XCTest
import Jotts
import CoreData

class SchedulerTests: XCTestCase {
    var context: NSManagedObjectContext?

    override func setUp() {
        self.context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    }

    func mockBuilding() -> Building {
        let building = Building(context: self.context!)

        building.rotationSize = 2
        building.scheduleDay = 0
        building.scheduleOrigin = Date(timeIntervalSinceMidnight: 0, from: Date(timeIntervalSinceReferenceDate: 0))
        building.rotationWeekdays = 0b1111111

        return building
    }

    func mockClassroom(building: Building) -> Classroom {
        let classroom = Classroom(context: self.context!)

        building.addToClassrooms(classroom)

        return classroom
    }

    func mockSchedule(classroom: Classroom) -> Schedule {
        let schedule = Schedule(context: self.context!)

        schedule.rotation = 0b11

        classroom.addToSchedule(schedule)

        return schedule
    }

    func testScheduleProgressionNone() throws {
        let building = self.mockBuilding()

        let _ = try building.schedule(for: building.scheduleOrigin!)

        XCTAssertEqual(building.scheduleDay, 0)
    }

    func testScheduleProgressionSingle() throws {
        let building = self.mockBuilding()

        let nextOrigin = Date(timeIntervalSinceMidnight: 86400, from: Date(timeIntervalSinceReferenceDate: 0))
        let _ = try building.schedule(for: nextOrigin)

        XCTAssertEqual(building.scheduleOrigin, nextOrigin)
        XCTAssertEqual(building.scheduleDay, 1)
    }

    func testScheduleProgressionDouble() throws {
        let building = self.mockBuilding()

        let nextOrigin = Date(timeIntervalSinceMidnight: 86400 * 2, from: Date(timeIntervalSinceReferenceDate: 0))
        let _ = try building.schedule(for: nextOrigin)

        XCTAssertEqual(building.scheduleOrigin, nextOrigin)
        XCTAssertEqual(building.scheduleDay, 0)
    }

    func testScheduleExclusion() throws {
        let building = self.mockBuilding()

        let exclusion = Date(timeIntervalSinceMidnight: 86400, from: Date(timeIntervalSinceReferenceDate: 0))

        building.rotationExclusions = [exclusion]

        let nextOrigin = Date(timeIntervalSinceMidnight: 86400 * 2, from: Date(timeIntervalSinceReferenceDate: 0))
        let _ = try building.schedule(for: nextOrigin)

        XCTAssertEqual(building.scheduleOrigin, nextOrigin)
        XCTAssertEqual(building.scheduleDay, 1)
    }

    func testScheduleSorting() throws {
        let building = self.mockBuilding()
        let classroom2 = self.mockClassroom(building: building)
        let classroom1 = self.mockClassroom(building: building)
        let schedule2 = self.mockSchedule(classroom: classroom2)
        let schedule1 = self.mockSchedule(classroom: classroom1)

        schedule1.startTime = 100
        schedule2.startTime = 200

        let classes = try building.schedule(for: building.scheduleOrigin!)

        XCTAssertEqual(building.scheduleDay, 0)

        XCTAssertEqual(classes.sessions.count, 2)
        XCTAssertEqual(classes.unscheduled.count, 0)

        // earlier classroom first
        XCTAssertEqual(classes.sessions[0].schedule, schedule1)
        XCTAssertNil(classes.sessions[0].session)
        XCTAssertEqual(classes.sessions[0].classroom, classroom1)
        // later classroom second
        XCTAssertEqual(classes.sessions[1].schedule, schedule2)
        XCTAssertNil(classes.sessions[1].session)
        XCTAssertEqual(classes.sessions[1].classroom, classroom2)
    }

    func testScheduleSortingMultiSchedule() throws {
        let building = self.mockBuilding()
        let classroom2 = self.mockClassroom(building: building)
        let classroom1 = self.mockClassroom(building: building)
        let schedule4 = self.mockSchedule(classroom: classroom2)
        let schedule2 = self.mockSchedule(classroom: classroom2)
        let schedule1 = self.mockSchedule(classroom: classroom1)
        let schedule3 = self.mockSchedule(classroom: classroom1)

        schedule2.startTime = 200
        schedule3.startTime = 300
        schedule4.startTime = 400
        schedule1.startTime = 100

        let classes = try building.schedule(for: building.scheduleOrigin!)

        XCTAssertEqual(building.scheduleDay, 0)

        XCTAssertEqual(classes.sessions.count, 4)
        XCTAssertEqual(classes.unscheduled.count, 0)

        // earliest schedule first
        XCTAssertEqual(classes.sessions[0].schedule, schedule1)
        XCTAssertNil(classes.sessions[0].session)
        XCTAssertEqual(classes.sessions[0].classroom, classroom1)
        // next earliest schedule
        XCTAssertEqual(classes.sessions[1].schedule, schedule2)
        XCTAssertNil(classes.sessions[1].session)
        XCTAssertEqual(classes.sessions[1].classroom, classroom2)
        // third earliest schedule
        XCTAssertEqual(classes.sessions[2].schedule, schedule3)
        XCTAssertNil(classes.sessions[2].session)
        XCTAssertEqual(classes.sessions[2].classroom, classroom1)
        // last schedule
        XCTAssertEqual(classes.sessions[3].schedule, schedule4)
        XCTAssertNil(classes.sessions[3].session)
        XCTAssertEqual(classes.sessions[3].classroom, classroom2)
    }
}
