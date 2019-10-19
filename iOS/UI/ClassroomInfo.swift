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
    @State private var scheduleEditorItem: Schedule?

    var schedulesRequest: FetchRequest<Schedule>
    var schedules: FetchedResults<Schedule>{schedulesRequest.wrappedValue}

    init(classroom: Classroom) {
        self.selectedClassroom = classroom

        self.schedulesRequest = FetchRequest(
            entity: Schedule.entity(),
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
                        if self.rotationSize == 7 && schedule.rotation == 0b0011111 {
                            label = "Weekdays"
                        } else if self.rotationSize == schedule.rotation.count() {
                            label = "Every Day"
                        } else {
                            label = "\(schedule.rotation.count()) Days"
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
                    schedule.classroom = self.selectedClassroom
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
                Text("Add Session")
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
