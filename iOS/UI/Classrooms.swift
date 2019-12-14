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
    @State var selectedClassroom: Classroom?

    var body: some View {
        NavigationView {
            ClassroomList(schedule: schedule, onChangeClassroom: { self.selectedClassroom = $0 })
                .navigationBarTitle("Classrooms")
                .navigationBarItems(trailing: Button(action: self.next.addClassroom) {
                    Image(systemName: "plus")
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 0))
                })
                .navigationBarHidden(isMacOS)
            Text("Select a Classroom")
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
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
