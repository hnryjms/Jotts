//
//  Classroom+CoreDataProperties.swift
//  Jotts
//
//  Created by Hank Brekke on 10/27/18.
//  Copyright © 2018 Hank Brekke. All rights reserved.
//
//

import Foundation
import CoreData

extension Classroom {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Classroom> {
        return NSFetchRequest<Classroom>(entityName: "Classroom")
    }

    @NSManaged public var color: String?
    @NSManaged public var instructor: String?
    @NSManaged public var networkID: String?
    @NSManaged public var room: String?
    @NSManaged public var title: String?
    @NSManaged public var assignments: NSSet?
    @NSManaged public var decks: NSSet?
    @NSManaged public var schedule: NSOrderedSet?
    @NSManaged public var sessions: NSSet?

}

// MARK: Generated accessors for assignments
extension Classroom {

    @objc(addAssignmentsObject:)
    @NSManaged public func addToAssignments(_ value: Assignment)

    @objc(removeAssignmentsObject:)
    @NSManaged public func removeFromAssignments(_ value: Assignment)

    @objc(addAssignments:)
    @NSManaged public func addToAssignments(_ values: NSSet)

    @objc(removeAssignments:)
    @NSManaged public func removeFromAssignments(_ values: NSSet)

}

// MARK: Generated accessors for decks
extension Classroom {

    @objc(addDecksObject:)
    @NSManaged public func addToDecks(_ value: Deck)

    @objc(removeDecksObject:)
    @NSManaged public func removeFromDecks(_ value: Deck)

    @objc(addDecks:)
    @NSManaged public func addToDecks(_ values: NSSet)

    @objc(removeDecks:)
    @NSManaged public func removeFromDecks(_ values: NSSet)

}

// MARK: Generated accessors for schedule
extension Classroom {

    @objc(insertObject:inScheduleAtIndex:)
    @NSManaged public func insertIntoSchedule(_ value: Schedule, at idx: Int)

    @objc(removeObjectFromScheduleAtIndex:)
    @NSManaged public func removeFromSchedule(at idx: Int)

    @objc(insertSchedule:atIndexes:)
    @NSManaged public func insertIntoSchedule(_ values: [Schedule], at indexes: NSIndexSet)

    @objc(removeScheduleAtIndexes:)
    @NSManaged public func removeFromSchedule(at indexes: NSIndexSet)

    @objc(replaceObjectInScheduleAtIndex:withObject:)
    @NSManaged public func replaceSchedule(at idx: Int, with value: Schedule)

    @objc(replaceScheduleAtIndexes:withSchedule:)
    @NSManaged public func replaceSchedule(at indexes: NSIndexSet, with values: [Schedule])

    @objc(addScheduleObject:)
    @NSManaged public func addToSchedule(_ value: Schedule)

    @objc(removeScheduleObject:)
    @NSManaged public func removeFromSchedule(_ value: Schedule)

    @objc(addSchedule:)
    @NSManaged public func addToSchedule(_ values: NSOrderedSet)

    @objc(removeSchedule:)
    @NSManaged public func removeFromSchedule(_ values: NSOrderedSet)

}

// MARK: Generated accessors for sessions
extension Classroom {

    @objc(addSessionsObject:)
    @NSManaged public func addToSessions(_ value: Session)

    @objc(removeSessionsObject:)
    @NSManaged public func removeFromSessions(_ value: Session)

    @objc(addSessions:)
    @NSManaged public func addToSessions(_ values: NSSet)

    @objc(removeSessions:)
    @NSManaged public func removeFromSessions(_ values: NSSet)

}
