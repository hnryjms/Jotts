//
//  ClassroomInfo.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import SwiftUI
import Introspect
import CoreData

struct ClassroomInfo: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentation
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

    private let rotationSize = AppDelegate.sharedDelegate().building.rotationSize

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

    @State private var titleText: UITextField?
    @State private var roomText: UITextField?
    @State private var instructorText: UITextField?

    private func nextTextField() {
        if titleText?.isFirstResponder == true {
            self.roomText?.becomeFirstResponder()
        } else if roomText?.isFirstResponder == true {
            self.instructorText?.becomeFirstResponder()
        } else if instructorText?.isFirstResponder == true {
            print("done")
        }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    classroomLabel
                    TextField("Psychology", text: $selectedClassroom.title.bound, onCommit: self.nextTextField)
                        .font(.title)
                        .introspectTextField { textField in
                            self.titleText = textField

                            textField.returnKeyType = .next
                            textField.attributedPlaceholder = NSAttributedString(
                                string: textField.placeholder!,
                                attributes: [
                                    .foregroundColor: UIColor.Jotts.textPlaceholder,
                                    .font: UIFont.preferredFont(forTextStyle: .title1)
                                ]
                            );
                        }
                    HStack {
                        TextField("R.123", text: $selectedClassroom.room.bound, onCommit: self.nextTextField)
                            .font(.body)
                            .frame(width: 65)
                            .keyboardType(.numbersAndPunctuation)
                            .introspectTextField { textField in
                                self.roomText = textField

                                textField.returnKeyType = .next
                                textField.attributedPlaceholder = NSAttributedString(
                                    string: textField.placeholder!,
                                    attributes: [
                                        .foregroundColor: UIColor.Jotts.textPlaceholder,
                                        .font: UIFont.preferredFont(forTextStyle: .body)
                                    ]
                                );
                            }
                        TextField("Smith", text: $selectedClassroom.instructor.bound, onCommit: self.nextTextField)
                            .font(.body)
                            .introspectTextField { textField in
                                self.instructorText = textField

                                textField.returnKeyType = .next
                                textField.attributedPlaceholder = NSAttributedString(
                                    string: textField.placeholder!,
                                    attributes: [
                                        .foregroundColor: UIColor.Jotts.textPlaceholder,
                                        .font: UIFont.preferredFont(forTextStyle: .body)
                                    ]
                                );
                            }
                    }
                }
                .foregroundColor(.white)
            }
            Section {
                ForEach(schedules, id: \.self) { schedule -> Button<Text> in
                    Button(action: {
                        self.scheduleEditorItem = schedule
                        self.isScheduleEditing = true
                    }) {
                        let label: Text
                        let count = schedule.rotation.count(rotationSize: self.rotationSize)
                        if self.rotationSize == 7 && schedule.rotation == 0b0011111 {
                            label = Text("Weekdays")
                        } else if self.rotationSize == count {
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
                    self.isScheduleEditing = true
                }) {
                    Text("Add Schedule")
                }
            }
            .listRowBackground(Color.white)
            .sheet(isPresented: $isScheduleEditing) {
                ScheduleEditor(schedule: self.scheduleEditorItem!, onClose: {
                    self.isScheduleEditing = false
                }).accentColor(Color(UIColor(fromHex: self.selectedClassroom.color)))
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
            .listRowBackground(Color.white)
            .sheet(isPresented: $isSessionEditing) {
                SessionEditor(session: self.sessionEditorItem!, onClose: {
                    self.isSessionEditing = false
                }).accentColor(Color(UIColor(fromHex: self.selectedClassroom.color)))
            }
        }
        .listStyle(GroupedListStyle())
        .introspectTableView(customize: { (tableView) in
            if isMacOS {
                tableView.backgroundColor = UIColor.Jotts.background
            }
        })
        .navigationBarHidden(isMacOS)
        .navigationBarTitle("\(selectedClassroom.title ?? "")", displayMode: .inline)
        .navigationBarItems(trailing: Group {
            Button(action: {
                self.isActionsOpen = true
            }) {
                Image(systemName: "ellipsis")
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 0))
            }
            .modifier(ActionButtonsModifier(isPresented: $isActionsOpen, title: Text(selectedClassroom.title ?? "Classroom"), buttons: [
                .destructive(Text("Delete Classroom")) {
                    self.managedObjectContext.delete(self.selectedClassroom)
                    self.presentation.wrappedValue.dismiss()
                },
                .cancel()
            ]))
        })

    }
}

struct ClassroomInfo_Previews: PreviewProvider {
    static var previews: some View {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let classroom = Classroom(context: context)

        let schedule = try! AppDelegate.sharedDelegate().building.schedule()
        let scheduleObservable = DailyScheduleObservable(schedule: schedule)

        return NavigationView {
            ClassroomInfo(classroom: classroom, schedule: scheduleObservable)
        }
        .environment(\.managedObjectContext, AppDelegate.sharedDelegate().persistentContainer.viewContext)
    }
}
