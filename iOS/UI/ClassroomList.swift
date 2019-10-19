//
//  ClassroomList.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import SwiftUI

struct ClassroomList: View {
    var classrooms: FetchedResults<Classroom>

    var body: some View {
        List {
            ForEach(classrooms, id: \.self) { classroom in
                NavigationLink(
                    destination: ClassroomInfo(classroom: classroom)
                        .onDisappear(perform: self.next.save)
                ) {
                    HStack {
                        Color(UIColor(fromHex: classroom.color ?? "#ff0000ff")!).frame(width: 12.0)
                        VStack(alignment: .leading, spacing: 1.0) {
                            Text("In (4) minutes")
                                .font(.subheadline)
                            Text(classroom.title ?? "No Title")
                                .font(.title)
                            Text("\(classroom.room ?? "No Room") - \(classroom.instructor ?? "No Instructor")")
                                .font(.body)
                        }
                        .padding(.top)
                        .padding(.bottom)
                    }
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 10))
                .listRowBackground(Color(white: 0.26))
                .foregroundColor(.white)
            }
        }
    }
}
