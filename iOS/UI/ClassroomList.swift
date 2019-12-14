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

    let onChangeClassroom: ((Classroom?) -> Void)

    func classroomInfo(_ classroom: Classroom) -> Text {
        let instructor = classroom.instructor ?? "No Instructor"
        if let room = classroom.room {
            if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: room)) {
                return Text("Room \(room) - \(instructor)", comment: "Room number, Instructor")
            }
        }

        return Text("\(classroom.room ?? "No Room") - \(instructor)", comment: "Room name, Instructor")
    }

    var body: some View {
        List {
            Section {
                ForEach(schedule.schedule.sessions, id: \.self) { session in
                    NavigationLink(
                        destination: ClassroomInfo(classroom: session.classroom, schedule: self.schedule)
                            .onAppear { self.onChangeClassroom(session.classroom) }
                            .onDisappear(perform: self.next.save)
                    ) {
                        HStack {
                            Color(UIColor(fromHex: session.classroom.color)).frame(width: 12.0)
                            VStack(alignment: .leading, spacing: 1.0) {
                                DailySessionText(session: session)
                                    .font(.subheadline)
                                Text(session.classroom.title ?? "No Title")
                                    .font(.title)
                                self.classroomInfo(session.classroom)
                                    .font(.body)
                            }
                            .padding(.top)
                            .padding(.bottom)
                        }
                    }
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 10))
                    .listRowBackground(Color(white: 0.26))
                    .foregroundColor(.white)
                }
            }
            Section {
                ForEach(schedule.schedule.unscheduled, id: \.self) { classroom in
                    NavigationLink(
                        destination: ClassroomInfo(classroom: classroom, schedule: self.schedule)
                            .onAppear { self.onChangeClassroom(classroom) }
                            .onDisappear(perform: self.next.save)
                    ) {
                        HStack {
                            Color(UIColor(fromHex: classroom.color)).frame(width: 12.0)
                            VStack(alignment: .leading, spacing: 1.0) {
                                Text("Not Scheduled Today")
                                    .font(.subheadline)
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
                    .listRowBackground(Color(white: 0.26))
                    .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            self.onChangeClassroom(nil)
        }
    }
}
