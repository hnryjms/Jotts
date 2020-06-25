//
//  ClassroomList.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import SwiftUI

struct ClassroomList: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject var schedule: DailyScheduleObservable

    @Binding var isSetupOpen: Bool

    func classroomSession(_ session: DailySession?) -> some View {
        if let dailySession = session {
            return AnyView(DailySessionText(session: dailySession)
                .font(.subheadline))
        } else {
            return AnyView(Text("Not Scheduled Today")
                .font(.subheadline))
        }
    }

    func classroomInfo(_ classroom: Classroom) -> Text {
        let instructor = classroom.instructor ?? "No Instructor"
        if let room = classroom.room {
            if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: room)) {
                return Text("Room \(room) - \(instructor)", comment: "Room number, Instructor")
            }
        }

        return Text("\(classroom.room ?? "No Room") - \(instructor)", comment: "Room name, Instructor")
    }

    func classroomRow(_ classroom: Classroom, session: DailySession? = nil) -> some View {
        NavigationLink(
            destination: ClassroomInfo(classroom: classroom, schedule: self.schedule)
        ) {
            HStack {
                Color(fromHex: classroom.color).frame(width: 12.0)
                VStack(alignment: .leading, spacing: 1.0) {
                    self.classroomSession(session)
                    Text(classroom.title ?? "No Title")
                        .font(.title)
                    self.classroomInfo(classroom)
                        .font(.body)
                }
                .padding(.top)
                .padding(.bottom)
            }
        }
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 10))
    }

    var body: some View {
        List {
            Section {
                ForEach(schedule.schedule.sessions, id: \.self) { session in
                    self.classroomRow(session.classroom, session: session)
                }
            }
            Section {
                ForEach(schedule.schedule.unscheduled, id: \.self) { classroom in
                    self.classroomRow(classroom)
                }
            }
            Section {
                Button(action: {
                    self.isSetupOpen = true
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "ellipsis")
                        Spacer()
                    }
                    .foregroundColor(.accentColor)
                }
                .listRowBackground(Color.clear)
                .foregroundColor(.white)
            }
        }
        .navigationTitle("Classrooms")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    let _ = Classroom.infer(context: self.managedObjectContext)

                    //todo: navigate
                }) {
                    Label("Add Classroom", systemImage: "plus")
                        .labelStyle(IconOnlyLabelStyle())
                }
            }
        }
    }
}

struct ClassroomList_Previews: PreviewProvider {
    @State static var isSetupOpen: Bool = false

    static var previews: some View {
        let building = Building.infer(context: globalViewContext)

        let schedule = try! building.schedule()

        return NavigationView {
            ClassroomList(
                schedule: DailyScheduleObservable(schedule: schedule),
                isSetupOpen: $isSetupOpen
            )
        }
        .environment(\.managedObjectContext, globalViewContext)
    }
}

