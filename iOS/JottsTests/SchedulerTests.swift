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

    private func mockBuilding() -> Building {
        let building = Building(context: self.context!)

        building.rotationSize = 2
        building.scheduleDay = 0
        building.scheduleOrigin = Date(timeIntervalSinceMidnight: 0, from: Date(timeIntervalSinceReferenceDate: 0))
        building.rotationWeekdays = 0b1111111

        return building
    }

    private func mockClassroom(building: Building) -> Classroom {
        let classroom = Classroom(context: self.context!)

        building.addToClassrooms(classroom)

        return classroom
    }

    private func mockSchedule(classroom: Classroom) -> Schedule {
        let schedule = Schedule(context: self.context!)

        schedule.rotation = 0b11

        classroom.addToSchedule(schedule)

        return schedule
    }

    private func mockSession(classroom: Classroom) -> Session {
        let session = Session(context: self.context!)

        classroom.addToSessions(session)

        return session
    }

    func testProgressionNone() throws {
        let building = self.mockBuilding()

        let _ = try building.schedule(for: building.scheduleOrigin!)

        XCTAssertEqual(building.scheduleDay, 0)
    }

    func testProgressionSingle() throws {
        let building = self.mockBuilding()

        let nextOrigin = Date(timeIntervalSinceMidnight: 86400, from: Date(timeIntervalSinceReferenceDate: 0))
        let _ = try building.schedule(for: nextOrigin)

        XCTAssertEqual(building.scheduleOrigin, nextOrigin)
        XCTAssertEqual(building.scheduleDay, 1)
    }

    func testProgressionDouble() throws {
        let building = self.mockBuilding()

        let nextOrigin = Date(timeIntervalSinceMidnight: 86400 * 2, from: Date(timeIntervalSinceReferenceDate: 0))
        let _ = try building.schedule(for: nextOrigin)

        XCTAssertEqual(building.scheduleOrigin, nextOrigin)
        XCTAssertEqual(building.scheduleDay, 0)
    }

    func testProgressionExclusion() throws {
        let building = self.mockBuilding()

        let exclusion = Date(timeIntervalSinceMidnight: 86400, from: Date(timeIntervalSinceReferenceDate: 0))

        building.rotationExclusions = [exclusion]

        let nextOrigin = Date(timeIntervalSinceMidnight: 86400 * 2, from: Date(timeIntervalSinceReferenceDate: 0))
        let _ = try building.schedule(for: nextOrigin)

        XCTAssertEqual(building.scheduleOrigin, nextOrigin)
        XCTAssertEqual(building.scheduleDay, 1)
    }

    func testPriorSchedulingError() throws {
        let building = self.mockBuilding()

        let nextOrigin = Date(timeIntervalSinceMidnight: -86400, from: Date(timeIntervalSinceReferenceDate: 0))

        XCTAssertThrowsError(try building.schedule(for: nextOrigin)) { error in
            XCTAssertEqual(error as? BuildingError, BuildingError.priorScheduling)
        }
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

    func testSessionSorting() throws {
        let building = self.mockBuilding()
        let classroom2 = self.mockClassroom(building: building)
        let classroom1 = self.mockClassroom(building: building)
        let session2 = self.mockSession(classroom: classroom2)
        let session1 = self.mockSession(classroom: classroom1)

        session1.startDate = Date(timeIntervalSinceMidnight: 100, from: building.scheduleOrigin!)
        session2.startDate = Date(timeIntervalSinceMidnight: 200, from: building.scheduleOrigin!)

        let classes = try building.schedule(for: building.scheduleOrigin!)

        XCTAssertEqual(building.scheduleDay, 0)

        XCTAssertEqual(classes.sessions.count, 2)
        XCTAssertEqual(classes.unscheduled.count, 0)

        // earlier classroom first
        XCTAssertNil(classes.sessions[0].schedule)
        XCTAssertEqual(classes.sessions[0].session, session1)
        XCTAssertEqual(classes.sessions[0].classroom, classroom1)
        // later classroom second
        XCTAssertNil(classes.sessions[1].schedule)
        XCTAssertEqual(classes.sessions[1].session, session2)
        XCTAssertEqual(classes.sessions[1].classroom, classroom2)
    }

    func testSessionSortingMultiSchedule() throws {
        let building = self.mockBuilding()
        let classroom2 = self.mockClassroom(building: building)
        let classroom1 = self.mockClassroom(building: building)
        let session4 = self.mockSession(classroom: classroom2)
        let session2 = self.mockSession(classroom: classroom2)
        let session1 = self.mockSession(classroom: classroom1)
        let session3 = self.mockSession(classroom: classroom1)

        session2.startDate = Date(timeIntervalSinceMidnight: 200, from: building.scheduleOrigin!)
        session3.startDate = Date(timeIntervalSinceMidnight: 300, from: building.scheduleOrigin!)
        session4.startDate = Date(timeIntervalSinceMidnight: 400, from: building.scheduleOrigin!)
        session1.startDate = Date(timeIntervalSinceMidnight: 100, from: building.scheduleOrigin!)

        let classes = try building.schedule(for: building.scheduleOrigin!)

        XCTAssertEqual(building.scheduleDay, 0)

        XCTAssertEqual(classes.sessions.count, 4)
        XCTAssertEqual(classes.unscheduled.count, 0)

        // earliest session first
        XCTAssertNil(classes.sessions[0].schedule)
        XCTAssertEqual(classes.sessions[0].session, session1)
        XCTAssertEqual(classes.sessions[0].classroom, classroom1)
        // next earliest session
        XCTAssertNil(classes.sessions[1].schedule)
        XCTAssertEqual(classes.sessions[1].session, session2)
        XCTAssertEqual(classes.sessions[1].classroom, classroom2)
        // third earliest session
        XCTAssertNil(classes.sessions[2].schedule)
        XCTAssertEqual(classes.sessions[2].session, session3)
        XCTAssertEqual(classes.sessions[2].classroom, classroom1)
        // last session
        XCTAssertNil(classes.sessions[3].schedule)
        XCTAssertEqual(classes.sessions[3].session, session4)
        XCTAssertEqual(classes.sessions[3].classroom, classroom2)
    }
}
