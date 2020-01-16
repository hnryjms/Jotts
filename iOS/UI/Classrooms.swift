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
                    .background(Color(UIColor.Jotts.background))
                    .edgesIgnoringSafeArea(.all)
                Text("Select a Classroom")
                    .foregroundColor(.white)
            }
            .background(Color(UIColor.Jotts.background))

        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .introspectNavigationController(customize: { (controller) in
            if isMacOS {
                controller.viewControllers[0].view.backgroundColor = .clear
            }
            if let splitView = controller.parent as? UISplitViewController {
                splitView.preferredDisplayMode = .allVisible
                splitView.primaryBackgroundStyle = .sidebar
            }
        })
        .sheet(isPresented: $isSetupOpen) {
            SetupWelcome(building: self.buildings[0])
        }
        .onAppear {
            if self.classrooms.count == 0 {
                self.isSetupOpen = true
            }
        }
        .accentColor(Color(UIColor(
            fromHex: self.selectedClassroom?.color,
            fallback: ColorHex.sorted[classrooms.count % ColorHex.sorted.count]
        )))
    }
}

struct Classrooms_Previews: PreviewProvider {
    static var previews: some View {
        let persistentContainer = AppDelegate.sharedDelegate().persistentContainer
        let building = AppDelegate.sharedDelegate().building

        let schedule = try! building.schedule()

        return Classrooms(schedule: DailyScheduleObservable(schedule: schedule))
            .environment(\.managedObjectContext, persistentContainer.viewContext)
    }
}
