//
//  ScheduleEditor.swift
//  Jotts
//
//  Created by Hank Brekke on 10/19/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import SwiftUI

struct ScheduleEditor: View {
    @ObservedObject var schedule: Schedule

    let rotationSize = AppDelegate.sharedDelegate().building.rotationSize
    let onClose: () -> Void

    var startDate: Binding<Date> {
        Binding(get: {
            Date(timeIntervalSinceMidnight: self.schedule.startTime)
        }) { newValue in
            self.schedule.objectWillChange.send()
            self.schedule.startTime = round(newValue.timeIntervalSinceMidnight / 60) * 60
        }
    }
    var endDate: Binding<Date> {
        Binding(get: {
            Date(timeIntervalSinceMidnight: self.schedule.startTime + self.schedule.length)
        }) { newValue in
            self.schedule.objectWillChange.send()
            self.schedule.length = round((newValue.timeIntervalSinceMidnight - self.schedule.startTime) / 60) * 60
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(0...self.rotationSize - 1, id: \.self) { index -> AnyView in
                        let label: Text
                        if self.rotationSize == 7 {
                            switch index {
                                case 0: label = Text("Monday")
                                case 1: label = Text("Tuesday")
                                case 2: label = Text("Wednesday")
                                case 3: label = Text("Thursday")
                                case 4: label = Text("Friday")
                                case 5: label = Text("Saturday")
                                case 6: label = Text("Sunday")
                                default: label = Text("UNKNOWN")
                            }
                        } else {
                            label = Text("Day \(index + 1)")
                        }

                        return AnyView(Button(action: {
                            self.schedule.objectWillChange.send()
                            if self.schedule.rotation.isSelected(day: index) {
                                self.schedule.rotation.deselect(day: index)
                            } else {
                                self.schedule.rotation.select(day: index)
                            }
                        }) {
                            HStack {
                                label
                                    .foregroundColor(.black)
                                if self.schedule.rotation.isSelected(day: index) {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        })
                    }
                }
                Section {
                    DatePicker(selection: self.startDate, displayedComponents: .hourAndMinute) {
                        Text("Class starts at")
                    }
                    DatePicker(selection: self.endDate, in: self.startDate.wrappedValue..., displayedComponents: .hourAndMinute) {
                        Text("Class ends at")
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Schedule")
            .navigationBarItems(trailing: Button(action: self.onClose) {
                Text("Done")
                    .bold()
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ScheduleEditor_Previews: PreviewProvider {
    static var previews: some View {
        let schedule = Schedule()
        return ScheduleEditor(schedule: schedule, onClose: { })
    }
}
