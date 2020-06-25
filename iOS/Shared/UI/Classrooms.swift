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

    let building: Building

    @FetchRequest(entity: Classroom.entity(), sortDescriptors: []) var classrooms: FetchedResults<Classroom>

    @State private var isSetupOpen: Bool = false

    var body: some View {
        NavigationView {
            ClassroomList(
                schedule: DailyScheduleObservable(schedule: try! building.schedule()),
                isSetupOpen: $isSetupOpen
            )
        }
        .sheet(isPresented: $isSetupOpen) {
            SetupWelcome(building: building)
        }
        .onAppear {
            if self.classrooms.count == 0 {
                self.isSetupOpen = true
            }
        }
    }
}

struct Classrooms_Previews: PreviewProvider {
    static var previews: some View {
        let building = Building.infer(context: globalViewContext)

        return Classrooms(building: building)
            .environment(\.managedObjectContext, globalViewContext)
    }
}
