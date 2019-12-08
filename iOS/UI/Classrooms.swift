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

    var body: some View {
        NavigationView {
            ClassroomList(schedule: schedule)
                .navigationBarTitle("Classrooms")
                .navigationBarItems(trailing: Button(action: self.next.addClassroom) {
                    Image(systemName: "plus")
                })
                .navigationBarHidden(isMacOS)
            Text("Select a Classroom")
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
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
