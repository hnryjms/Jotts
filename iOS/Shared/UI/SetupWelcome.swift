//
//  SetupWelcome.swift
//  Jotts
//
//  Created by Hank Brekke on 12/14/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import SwiftUI

struct SetupWelcome: View {
    @Environment(\.presentationMode) var presentation

    let building: Building

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                Spacer()
                Image(systemName: "bell.fill")
                    .padding(.bottom, 50)
                    .font(.system(size: 100))
                Text("Jotts is a modern organizer for students. Add your schedule, and check where to go any time during your first day, or any day.")
                    .multilineTextAlignment(.center)
                Spacer()
                VStack(spacing: 20) {
                    NavigationLink(destination: SetupTypeSelector(parentPresentation: presentation, building: building)) {
                        HStack {
                            Spacer()
                            Text("Setup My Schedule")
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(8)
                    Button(action: {
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        Text("Skip Setup")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .padding()
            .navigationBarTitle("Welcome")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SetupTypeSelector: View {
    @Binding var parentPresentation: PresentationMode
    @ObservedObject var building: Building

    var body: some View {
        List {
            Section {
                Button(action: {
                    self.building.objectWillChange.send()
                    self.building.rotationSize = 7
                    self.building.rotationExclusions = []
                    self.building.rotationWeekdays = 0

                    self.parentPresentation.dismiss()
                }) {
                    Text("My schedule is the same every week")
                        .foregroundColor(.black)
                }
                NavigationLink(destination: SetupRotation(building: building)) {
                    Text("My schedule rotates on a cycle")
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Schedule Type", displayMode: .inline)
    }
}

struct SetupWelcome_Previews: PreviewProvider {
    static var previews: some View {
        let building = Building.infer(context: globalViewContext)

        return SetupWelcome(building: building)
    }
}
