//
//  SessionEditor.swift
//  Jotts
//
//  Created by Hank Brekke on 11/10/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import SwiftUI

struct SessionEditor: View {
    @ObservedObject var session: Session

    let onClose: () -> Void

    var startDate: Binding<Date> {
        Binding(get: {
            self.session.startDate ?? Date()
        }) { newValue in
            self.session.objectWillChange.send()
            self.session.startDate = Date(timeIntervalSinceReferenceDate: round(newValue.timeIntervalSinceReferenceDate / 60) * 60)
        }
    }
    var endDate: Binding<Date> {
        Binding(get: {
            Date(timeInterval: self.session.length, since: self.startDate.wrappedValue)
        }) { newValue in
            self.session.objectWillChange.send()
            self.session.length = round((newValue.timeIntervalSinceMidnight - self.startDate.wrappedValue.timeIntervalSinceMidnight) / 60) * 60
        }
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    DatePicker(selection: self.startDate, displayedComponents: [.date, .hourAndMinute]) {
                        Text("Class starts at")
                    }
                    DatePicker(selection: self.endDate, in: self.startDate.wrappedValue..., displayedComponents: .hourAndMinute) {
                        Text("Class ends at")
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Session")
            .navigationBarItems(trailing: Button(action: self.onClose) {
                Text("Done")
                    .bold()
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SessionEditor_Previews: PreviewProvider {
    static var previews: some View {
        let schedule = Schedule()
        return ScheduleEditor(schedule: schedule, onClose: { })
    }
}
