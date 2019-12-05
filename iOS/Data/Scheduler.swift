//
//  Scheduler.swift
//  Jotts
//
//  Created by Hank Brekke on 11/21/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import Foundation

enum BuildingError: Error {
    case priorScheduling
}

public struct DailySession: Hashable {
    public let session: Session?
    public let schedule: Schedule?
    public let classroom: Classroom

    public func endDate() -> Date {
        if let session = self.session {
            return Date(timeInterval: session.length, since: session.startDate!)
        }

        return Date(timeIntervalSinceMidnight: self.schedule!.startTime + self.schedule!.length)
    }
    public func startDate() -> Date {
        if let session = self.session {
            return session.startDate!
        }

        return Date(timeIntervalSinceMidnight: self.schedule!.startTime)
    }
}

public struct DailySchedule {
    public let sessions: [DailySession]
    public let unscheduled: [Classroom]
}

extension Building {
    public func schedule(for date: Date = Date()) throws -> DailySchedule {
        if let scheduleOrigin = self.scheduleOrigin {
            if scheduleOrigin > date {
                throw BuildingError.priorScheduling
            }

            let nextScheduleOrigin = Date(timeIntervalSinceMidnight: 0, from: date)

            if self.rotationSize == 7 {
                // Using a 7-day rotation means a weekly schedule, so always origin around Monday to
                // match UI behavior in ScheduleEditor.

                let closestMonday = Calendar.current.date(bySetting: .weekday, value: 2, of: nextScheduleOrigin)!
                let mondayDiffComponents = Calendar.current.dateComponents([ .day ], from: closestMonday, to: nextScheduleOrigin)

                // Shift future Monday's to last week using `%`
                self.scheduleDay = Int16(7 + mondayDiffComponents.day! % 7)
                self.scheduleOrigin = nextScheduleOrigin
            } else {
                let originDiffComponents = Calendar.current.dateComponents([ .day ], from: scheduleOrigin, to: nextScheduleOrigin)

                if originDiffComponents.day! > 0 {
                    var scheduleDay = self.scheduleDay
                    for day in 1...originDiffComponents.day! {
                        let date = Calendar.current.date(byAdding: .day, value: day, to: scheduleOrigin)!
                        let components = Calendar.current.dateComponents([ .weekday ], from: date)

                        if let rotationExclusions = self.rotationExclusions {
                            let isExcluded = rotationExclusions.contains { exclusion -> Bool in
                                return Calendar.current.isDate(date, inSameDayAs: exclusion)
                            }
                            if isExcluded {
                                continue
                            }
                        }

                        if self.rotationWeekdays.isSelected(day: Int16(components.weekday!)) {
                            scheduleDay += 1
                        }
                    }

                    self.scheduleDay = scheduleDay % self.rotationSize
                    self.scheduleOrigin = nextScheduleOrigin
                }
            }

            guard let classrooms = self.classrooms?.allObjects as? [Classroom] else {
                return DailySchedule(sessions: [], unscheduled: [])
            }

            let allSessions: [Session] = classrooms.reduce([]) { allSessions, classroom in
                guard let sessions = classroom.sessions?.allObjects as? [Session] else {
                    return allSessions
                }

                return allSessions + sessions.filter({ session -> Bool in
                    return Calendar.current.isDate(session.startDate!, inSameDayAs: nextScheduleOrigin)
                })
            }
            let allSchedules: [Schedule] = classrooms.reduce([]) { allSchedules, classroom in
                guard let schedules = classroom.schedule?.array as? [Schedule] else {
                    return allSchedules
                }

                return allSchedules + schedules.filter { schedule -> Bool in
                    return schedule.rotation.isSelected(day: self.scheduleDay)
                }
            }

            let dailySessions: [DailySession] = allSessions
                .map { session in
                    return DailySession(session: session, schedule: nil, classroom: session.classroom!)
                } + allSchedules.map({ schedule in
                    return DailySession(session: nil, schedule: schedule, classroom: schedule.classroom!)
                })
            let unscheduled: [Classroom] = classrooms.filter { classroom -> Bool in
                return !dailySessions.contains { dailySession -> Bool in
                    return dailySession.classroom == classroom
                }
            }

            return DailySchedule(
                sessions: dailySessions.sorted(by: { (a, b) -> Bool in
                    return a.startDate() < b.startDate()
                }),
                unscheduled: unscheduled
            )
        } else {
            self.scheduleOrigin = Date()
            return try self.schedule(for: date)
        }
    }
}
