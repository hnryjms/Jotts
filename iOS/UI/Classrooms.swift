//
//  Classrooms.swift
//  Jotts
//
//  Created by Hank Brekke on 10/13/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import SwiftUI

#if targetEnvironment(macCatalyst)
fileprivate let isMacOS = true
#else
fileprivate let isMacOS = false
#endif

struct Classrooms: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: Classroom.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Classroom.title, ascending: true)
        ]
    ) var classrooms: FetchedResults<Classroom>

    var body: some View {
        NavigationView {
            ClassroomList(classrooms: classrooms)
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
        return Classrooms()
            .environment(\.managedObjectContext, persistentContainer.viewContext)
    }
}
