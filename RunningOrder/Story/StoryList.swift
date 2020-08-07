//
//  StoryList.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

extension Story: Identifiable {
    var id: String { ticketReference }
}

struct StoryList: View {
    var sprintIndex: Int

    var sprint: Sprint {
        return sprintManager.sprints[sprintIndex]
    }

    @EnvironmentObject var toolbarManager: ToolbarManager
    @EnvironmentObject var sprintManager: SprintManager

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Sprint \(sprint.number) - \(sprint.name)")
                    .font(.headline)
                    .padding(5)
                List {
                    ForEach(sprint.stories.indices, id: \.self) { index in
                        NavigationLink(
                            destination: StoryDetail(sprintIndex: sprintIndex, storyIndex: index),
                            label: { StoryRow(sprintIndex: sprintIndex, storyIndex: index) }
                        )
                    }
                }
            }
            .background(Color("snowbank"))

            .frame(minWidth: 100, maxWidth: 200, maxHeight: .infinity)

            Text("Select a Story")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
        }
        .sheet(isPresented: $toolbarManager.isAddStoryButtonClicked) {
            NewStoryView(createdStory: self.$sprintManager.sprints[sprintIndex].stories.appendedElement)
        }
        .onAppear {
            // enabling toolbar add story button
            toolbarManager.isASprintSelected = true
        }
        .onDisappear {
            // disabling toolbar add story button
            toolbarManager.isASprintSelected = false
        }
    }
}

struct StoryList_Previews: PreviewProvider {
    static var previews: some View {
        StoryList(sprintIndex: 0)
    }
}
