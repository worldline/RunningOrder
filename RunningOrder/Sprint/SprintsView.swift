//
//  SprintsView.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

extension Array {
    /// Useful for Binding when waiting for new element to come, but want to create one, so no get to provide
    ///
    /// This variable works only with Bindings that are nil first, then filled when completes and want to add directly the value to the array
    var appendedElement: Element? {
        get {
            return nil
        }

        set {
            if let realNewValue = newValue {
                self.append(realNewValue)
            }
        }
    }
}

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
