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

    let sprint: Sprint

    @EnvironmentObject var toolbarManager: ToolbarManager
    @EnvironmentObject var storyManager: StoryManager

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Sprint \(sprint.number) - \(sprint.name)")
                    .font(.headline)
                    .padding(13)
                List {
                    Divider()
                    ForEach(storyManager.stories.indices, id: \.self) { index in
                        NavigationLink(
                            destination: StoryDetail(storyIndex: index),
                        label: { StoryRow(story: storyManager.stories[index]) }
                        )
                        Divider()
                    }
                }
                .colorMultiply(Color("concrete"))
            }
            .background(Color("concrete"))

            .frame(minWidth: 100, maxWidth: 400)

            Text("Select a Story")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
        }
        .sheet(isPresented: $toolbarManager.isAddStoryButtonClicked) {
            NewStoryView(sprintId: sprint.id, createdStory: $storyManager.stories.appendedElement, onAddingStory: { story in
                Story.Previews.stories.append(story)
            })
        }
        .onAppear {
            // enabling toolbar add story button
            toolbarManager.isASprintSelected = true
            storyManager.fetchStories(sprintId: sprint.id)
        }
        .onDisappear {
            // disabling toolbar add story button
            toolbarManager.isASprintSelected = false
        }
    }
}

struct StoryList_Previews: PreviewProvider {
    static var previews: some View {
        StoryList(sprint: Sprint.Previews.sprints[0])
            .environmentObject(SprintManager())
    }
}
