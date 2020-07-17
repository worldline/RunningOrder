//
//  SprintList.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

extension Sprint: Identifiable {
    var id: String { self.name }
}

struct SprintList: View {
    @State private var sprints: [Sprint] = []
    @State private var showNewSprintModal = false

    var body: some View {
        List {
            Section(header: Text("Active Sprints")) {
                ForEach(sprints) { sprint in
                    NavigationLink(
                        destination: StoryList(stories: sprint.stories)
                            .listStyle(PlainListStyle()),
                        label: {
                            Text(sprint.name)
                        })
                }
            }

            Button(action: { self.showNewSprintModal.toggle() }) {
                Text("New Sprint")
            }
            Section(header: Text("Old Sprints")) {
                EmptyView()
            }

        }.sheet(isPresented: $showNewSprintModal) {
            NewSprintView(createdSprint: self.$sprints.appendedElement)
        }
    }
}

struct SprintList_Previews: PreviewProvider {
    static var previews: some View {
        SprintList()
            .listStyle(SidebarListStyle())
            .frame(width: 250)
    }
}
