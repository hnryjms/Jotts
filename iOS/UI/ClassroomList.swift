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

    var body: some View {
        List {
            Section {
                ForEach(schedule.schedule.sessions, id: \.self) { session in
                    NavigationLink(
                        destination: ClassroomInfo(classroom: session.classroom)
                            .onDisappear(perform: self.next.save)
                    ) {
                        HStack {
                            Color(UIColor(fromHex: session.classroom.color ?? "#ff0000ff")!).frame(width: 12.0)
                            VStack(alignment: .leading, spacing: 1.0) {
                                Text("In (4) minutes")
                                    .font(.subheadline)
                                Text(session.classroom.title ?? "No Title")
                                    .font(.title)
                                Text("\(session.classroom.room ?? "No Room") - \(session.classroom.instructor ?? "No Instructor")")
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
                        destination: ClassroomInfo(classroom: classroom)
                            .onDisappear(perform: self.next.save)
                    ) {
                        HStack {
                            Color(UIColor(fromHex: classroom.color ?? "#ff0000ff")!).frame(width: 12.0)
                            VStack(alignment: .leading, spacing: 1.0) {
                                Text("Not Scheduled Today")
                                    .font(.subheadline)
                                Text(classroom.title ?? "No Title")
                                    .font(.title)
                                Text("\(classroom.room ?? "No Room") - \(classroom.instructor ?? "No Instructor")")
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
    }
}
