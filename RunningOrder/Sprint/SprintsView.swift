//
//  SprintsView.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

extension Sprint: Identifiable {
    var id: String { self.name }
}

struct SprintsView: View {
    @State private var sprints: [Sprint] = []
    @State private var showNewSprintModal = false

    @Binding var selectedSprint: Sprint?

    var body: some View {
        List(selection: $selectedSprint) {
            Section(header: Text("Active Sprints")) {
                ForEach(sprints) { sprint in
                    Text(sprint.name)
                        .tag(sprint)
                }

                Button(action: { self.showNewSprintModal.toggle() }) {
                    HStack {
                        Text("New Sprint")
                    }
                }
            }

            Section(header: Text("Old Sprints")) {
                EmptyView()
            }
        }.sheet(isPresented: $showNewSprintModal) {
            NewSprintView(createdSprint: self.$sprints.appendedElement)
        }
    }
}

struct SprintsView_Previews: PreviewProvider {
    static var previews: some View {
        SprintsView(selectedSprint: .constant(nil))
            .listStyle(SidebarListStyle())
        .frame(width: 250)
    }
}
