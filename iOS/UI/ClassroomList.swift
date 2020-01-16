//
//  ClassroomList.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import SwiftUI

struct ClassroomList: View {
    @ObservedObject var schedule: DailyScheduleObservable

    @Binding var selectedClassroom: Classroom?
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
                .onAppear { self.selectedClassroom = classroom }
                .onDisappear(perform: self.next.save)
        ) {
            HStack {
                Color(UIColor(fromHex: classroom.color)).frame(width: 12.0)
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
        .foregroundColor(.white)
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
        .onAppear {
            self.selectedClassroom = nil
        }
        .navigationBarTitle("Classrooms")
        .navigationBarItems(trailing: Button(action: self.next.addClassroom) {
            Image(systemName: "plus")
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 0))
        })
        .navigationBarHidden(isMacOS)
        .introspectTableView { (tableView) in
            if isMacOS {
                tableView.backgroundColor = .clear
            }
        }
    }
}

struct ClassroomList_Previews: PreviewProvider {
    @State static var classroom: Classroom? = nil
    @State static var isSetupOpen: Bool = false

    static var previews: some View {
        let building = AppDelegate.sharedDelegate().building
        let schedule = try! building.schedule()

        return ClassroomList(
            schedule: DailyScheduleObservable(schedule: schedule),
            selectedClassroom: $classroom,
            isSetupOpen: $isSetupOpen
        )
    }
}

