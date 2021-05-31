//
//  SprintRow.swift
//  RunningOrder
//
//  Created by Clément Nonn on 31/05/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI

struct SprintRow: View {
    @EnvironmentObject var sprintManager: SprintManager
    @Binding var sprintToDelete: Sprint?

    let sprint: Sprint

    var body: some View {
        InternalView(
            sprint: sprint,
            logic: Logic(sprintManager: sprintManager, sprintToDeleteBinding: _sprintToDelete)
        )
    }
}

extension SprintRow {
    fileprivate struct InternalView: View {
        let sprint: Sprint
        @ObservedObject var logic: Logic
        @State private var showDeletionConfirmation = false

        var body: some View {
            NavigationLink(
                destination: StoryList(sprint: sprint),
                label: {
                    HStack {
                        SprintNumber(
                            number: sprint.number,
                            colorIdentifier: sprint.colorIdentifier
                        )
                        Text(sprint.name)
                    }
                }
            )
            .contextMenu {
                if sprint.closed {
                    Button("Reopen Sprint") {
                        logic.reopenSprint(sprint)
                    }
                } else {
                    Button("Close Sprint") {
                        logic.closeSprint(sprint)
                    }
                }

                Button("Delete Sprint") {
                    logic.deleteSprint(sprint)
                }
            }
        }
    }

}

struct SprintRow_Previews: PreviewProvider {
    static var previews: some View {
        SprintRow(sprintToDelete: .constant(nil), sprint: Sprint.Previews.sprints.first!)
            .environmentObject(SprintManager.preview)
    }
}
