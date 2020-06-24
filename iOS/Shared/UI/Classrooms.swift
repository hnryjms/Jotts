//
//  Classrooms.swift
//  Jotts
//
//  Created by Hank Brekke on 10/13/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import SwiftUI

struct Classrooms: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    @ObservedObject var schedule: DailyScheduleObservable

    @FetchRequest(entity: Classroom.entity(), sortDescriptors: []) var classrooms: FetchedResults<Classroom>
    @FetchRequest(entity: Building.entity(), sortDescriptors: []) var buildings: FetchedResults<Building>

    @State private var selectedClassroom: Classroom?
    @State private var isSetupOpen: Bool = false

    var body: some View {
        NavigationView {
            ClassroomList(
                schedule: schedule,
                selectedClassroom: $selectedClassroom,
                isSetupOpen: $isSetupOpen
            )
            ZStack {
                Text(" ")
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .background(Color.Jotts.background)
                    .edgesIgnoringSafeArea(.all)
                Text("Select a Classroom")
                    .foregroundColor(.white)
            }
            .background(Color.Jotts.background)

        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .sheet(isPresented: $isSetupOpen) {
            SetupWelcome(building: self.buildings[0])
        }
        .onAppear {
            if self.classrooms.count == 0 {
                self.isSetupOpen = true
            }
        }
        .accentColor(Color(
            fromHex: self.selectedClassroom?.color,
            fallback: ColorHex.sorted[classrooms.count % ColorHex.sorted.count]
        ))
    }
}

struct Classrooms_Previews: PreviewProvider {
    static var previews: some View {
        let schedule = try! globalBuilding.schedule()

        return Classrooms(schedule: DailyScheduleObservable(schedule: schedule))
            .environment(\.managedObjectContext, globalPersistentContainer.viewContext)
    }
}
