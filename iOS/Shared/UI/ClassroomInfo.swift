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
    @Environment(\.presentationMode) var presentation
    @Environment(\.building) var building

    @ObservedObject var selectedClassroom: Classroom
    @ObservedObject var schedule: DailyScheduleObservable

    @State var isActionsOpen: Bool = false

    var session: DailySession? {
        get {
            return self.schedule.schedule.sessions.first { session -> Bool in
                return session.classroom === self.selectedClassroom
            }
        }
    }

    @State private var isScheduleEditing = false
    @State private var isSessionEditing = false
    @State private var scheduleEditorItem: Schedule?
    @State private var sessionEditorItem: Session?

    private var schedulesRequest: FetchRequest<Schedule>
    private var schedules: FetchedResults<Schedule>{schedulesRequest.wrappedValue}
    private var sessionsRequest: FetchRequest<Session>
    private var sessions: FetchedResults<Session>{sessionsRequest.wrappedValue}

    init(classroom: Classroom, schedule: DailyScheduleObservable) {
        self.selectedClassroom = classroom
        self.schedule = schedule

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

    var classroomLabel: some View {
        if let session = self.session {
            return AnyView(
                DailySessionText(session: session)
                    .font(.subheadline)
            )
        } else {
            return AnyView(
                Text("Not Scheduled Today")
                    .font(.subheadline)
            )
        }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    classroomLabel
                    TextField("Psychology", text: $selectedClassroom.title.bound)
                        .font(.title)
                    HStack {
                        TextField("R.123", text: $selectedClassroom.room.bound)
                            .font(.body)
                            .frame(width: 65)
                            .keyboardType(.numbersAndPunctuation)
                        TextField("Smith", text: $selectedClassroom.instructor.bound)
                            .font(.body)
                    }
                }
            }
            Section {
                ForEach(schedules, id: \.self) { schedule -> Button<Text> in
                    Button(action: {
                        self.scheduleEditorItem = schedule
                    }) { () -> Text in
                        let label: Text
                        let count = schedule.rotation.count(rotationSize: building.rotationSize)
                        if building.rotationSize == 7 && schedule.rotation == 0b0011111 {
                            label = Text("Weekdays")
                        } else if building.rotationSize == count {
                            label = Text("Every Day")
                        } else {
                            label = Text("\(count) Days", comment: "Count")
                        }

                        return label
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
                }) {
                    Text("Add Schedule")
                }
            }
            .listRowBackground(Color.white)
            .sheet(isPresented: $isScheduleEditing) {
                if let schedule = self.scheduleEditorItem {
                    ScheduleEditor(schedule: schedule, onClose: {
                        self.isScheduleEditing = false
                    })
                } else {
                    Text("TBD")
                }

            }
            Section {
                ForEach(sessions, id: \.self) { session -> Button<Text> in
                    Button(action: {
                        self.sessionEditorItem = session
                    }) { () -> Text in

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
            .listRowBackground(Color.white)
            .sheet(isPresented: $isSessionEditing) {
                if let session = self.sessionEditorItem {
                    SessionEditor(session: session, onClose: {
                        self.isSessionEditing = false
                    })
                } else {
                    Text("TBD")
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("\(selectedClassroom.title ?? "")", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {}) {
                    Label("All Actions", systemImage: "ellipsis")
                        .labelStyle(IconOnlyLabelStyle())
                }
                .contextMenu {
                    Button(action: {
                        self.managedObjectContext.delete(self.selectedClassroom)
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        Label("Delete Classroom", systemImage: "trash")
                            .accentColor(.red)
                    }
                }
            }
        }
    }
}

struct ClassroomInfo_Previews: PreviewProvider {
    static var previews: some View {
        let building = Building.infer(context: globalViewContext)
        let classroom = Classroom.infer(context: globalViewContext)

        classroom.title = "English"
        classroom.room = "R.232"
        classroom.instructor = "McCoy"

        let schedule = try! building.schedule()

        return Group {
            NavigationView {
                ClassroomInfo(
                    classroom: classroom,
                    schedule: DailyScheduleObservable(schedule: schedule)
                )
            }
        }
        .environment(\.managedObjectContext, globalViewContext)
    }
}
