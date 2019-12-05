//
//  ClassroomInfo.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import SwiftUI
import CoreData

struct ClassroomInfo: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var selectedClassroom: Classroom

    let rotationSize = AppDelegate.sharedDelegate().building.rotationSize

    @State private var isScheduleEditing = false
    @State private var isSessionEditing = false
    @State private var scheduleEditorItem: Schedule?
    @State private var sessionEditorItem: Session?

    var schedulesRequest: FetchRequest<Schedule>
    var schedules: FetchedResults<Schedule>{schedulesRequest.wrappedValue}
    var sessionsRequest: FetchRequest<Session>
    var sessions: FetchedResults<Session>{sessionsRequest.wrappedValue}

    init(classroom: Classroom) {
        self.selectedClassroom = classroom

        self.schedulesRequest = FetchRequest(
            entity: Schedule.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "classroom == %@", classroom)
        )

        self.sessionsRequest = FetchRequest(
            entity: Session.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "classroom == %@", classroom)
        )
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    Text("In (4) minutes")
                        .font(.subheadline)
                    TextField("Psychology", text: $selectedClassroom.title.bound)
                        .font(.title)
                    HStack {
                        TextField("P.123", text: $selectedClassroom.room.bound)
                            .font(.body)
                            .frame(width: 65)
                            .keyboardType(.numbersAndPunctuation)
                        TextField("Smith", text: $selectedClassroom.instructor.bound)
                            .font(.body)
                    }
                }
                .listRowBackground(Color(white: 0.26))
                .foregroundColor(.white)
            }
            Section {
                ForEach(schedules, id: \.self) { schedule -> Button<Text> in
                    Button(action: {
                        self.scheduleEditorItem = schedule
                        self.isScheduleEditing = true
                    }) {
                        let label: String
                        let count = schedule.rotation.count(rotationSize: self.rotationSize)
                        if self.rotationSize == 7 && schedule.rotation == 0b0011111 {
                            label = "Weekdays"
                        } else if self.rotationSize == count {
                            label = "Every Day"
                        } else {
                            label = "\(count) Days"
                        }

                        return Text(label)
                            .foregroundColor(.black)
                    }
                }
                .onDelete { offsets in
                    for index in offsets {
                        let schedule = self.schedules[index]
                        self.managedObjectContext.delete(schedule)
                    }
                }
                Button(action: {
                    let schedule = Schedule(context: self.managedObjectContext)

                    self.selectedClassroom.addToSchedule(schedule)
                    self.scheduleEditorItem = schedule
                    self.isScheduleEditing = true
                }) {
                    Text("Add Schedule")
                }
            }
            .sheet(isPresented: $isScheduleEditing) {
                ScheduleEditor(schedule: self.scheduleEditorItem!, onClose: {
                    self.isScheduleEditing = false
                })
            }
            Section {
                ForEach(sessions, id: \.self) { session -> Button<Text> in
                    Button(action: {
                        self.sessionEditorItem = session
                        self.isSessionEditing = true
                    }) {

                        let startText: String
                        if let startDate = session.startDate {
                            let dateFormat = DateFormatter()
                            dateFormat.dateStyle = .short
                            dateFormat.timeStyle = .short

                            startText = dateFormat.string(from: startDate)
                        } else {
                            startText = "Unscheduled"
                        }
                        return Text(startText)
                            .foregroundColor(.black)
                    }
                }
                .onDelete { offsets in
                    for index in offsets {
                        let session = self.sessions[index]
                        self.managedObjectContext.delete(session)
                    }
                }
                Button(action: {
                    let session = Session(context: self.managedObjectContext)
                    session.startDate = Date()

                    self.selectedClassroom.addToSessions(session)
                    self.sessionEditorItem = session
                    self.isSessionEditing = true
                }) {
                    Text("Add Session")
                }
            }
            .sheet(isPresented: $isSessionEditing) {
                SessionEditor(session: self.sessionEditorItem!, onClose: {
                    self.isSessionEditing = false
                })
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(selectedClassroom.title ?? "")
    }
}

struct ClassroomInfo_Previews: PreviewProvider {
    static var previews: some View {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let classroom = Classroom(context: context)

        return ClassroomInfo(classroom: classroom)
    }
}
