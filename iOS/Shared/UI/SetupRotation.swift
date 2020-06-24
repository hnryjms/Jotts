//
//  SetupRotation.swift
//  Jotts
//
//  Created by Hank Brekke on 12/14/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import SwiftUI

struct SetupRotation: View {
    @ObservedObject var building: Building
    @Binding var parentPresentation: PresentationMode

    @State var _int_rotationSize: String?
    private var rotationSize: Binding<String> {
        Binding(get: {
            return self._int_rotationSize ?? String(self.building.rotationSize)
        }) { newValue in
            self._int_rotationSize = newValue

            self.building.objectWillChange.send()
            self.building.scheduleOrigin = Date(timeIntervalSinceMidnight: 0)
            self.building.rotationSize = Int16(newValue) ?? 0
        }
    }

    @State var _int_scheduleDay: String?
    private var scheduleDay: Binding<String> {
        Binding(get: {
            return self._int_scheduleDay ?? String(self.building.scheduleDay + 1)
        }) { newValue in
            self._int_scheduleDay = newValue

            self.building.objectWillChange.send()
            self.building.scheduleOrigin = Date(timeIntervalSinceMidnight: 0)
            self.building.scheduleDay = (Int16(newValue) ?? 1) - 1
        }
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Rotation Size")
                    TextField("", text: rotationSize)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
                if self.building.rotationSize != 7 {
                    HStack {
                        Text("Current Day")
                        TextField("", text: scheduleDay)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .listRowBackground(Color.white)
            if self.building.rotationSize != 7 {
                Section(header: Text("Included in Rotation:")) {
                    ForEach(0...Int16(6), id: \.self) { index -> AnyView in
                        let label: Text
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

                        return AnyView(Button(action: {
                            self.building.objectWillChange.send()
                            if self.building.rotationWeekdays.isSelected(day: index) {
                                self.building.rotationWeekdays.deselect(day: index)
                            } else {
                                self.building.rotationWeekdays.select(day: index)
                            }
                        }) {
                            HStack {
                                label
                                    .foregroundColor(.black)
                                if self.building.rotationWeekdays.isSelected(day: index) {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        })
                    }
                }
                .listRowBackground(Color.white)
                /*Section(
                    header: Text("Custom Rotation Exclusions:"),
                    footer: Text("You can add holidays or other time off that shouldn't update the rotation.")
                ) {
                    Text("Coming Soon")
                }
                .listRowBackground(Color.white)*/
            }
        }
        .navigationBarItems(trailing: Button(action: {
            self.parentPresentation.dismiss()
        }) {
            Text("Done").bold()
        })
    }
}
