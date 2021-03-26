//
//  StoryList.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

extension Story: Identifiable {}

extension StoryList {
    fileprivate struct InternalView: View {
        let sprint: Sprint

        @ObservedObject var logic: Logic
        @EnvironmentObject var storyManager: StoryManager
        @State private var selected: Story?

        var body: some View {
            List(storyManager.stories(for: sprint.id) , id: \.self, selection: $selected) { story in
                VStack {
                    NavigationLink(
                        destination: StoryDetail(story: story)
                            .epicColor(Color(identifier: logic.epicColor(for: story))),
                        label: { StoryRow(story: story) }
                    )
                    .contextMenu {
                        Button(
                            action: { logic.deleteStory(story) },
                            label: { Text("Delete Story") }
                        )
                    }
                    .epicColor(Color(identifier: logic.epicColor(for: story)))

                    if story == selected {
                        Divider()
                            .hidden()
                    } else {
                        Divider()
                    }
                }
            }
            .navigationTitle("Sprint \(sprint.number) - \(sprint.name)")
            .frame(minWidth: 100, idealWidth: 300)
            .toolbar {
                ToolbarItems.sidebarItem

                ToolbarItemGroup(placement: ToolbarItemPlacement.cancellationAction) {

                        Button(action: logic.showAddStoryView) {
                            Image(systemName: "square.and.pencil")
                        }
                }
            }
            .sheet(isPresented: $logic.isAddStoryViewDisplayed) {
                NewStoryView(sprintId: sprint.id, createdStory: logic.createdStoryBinding)
            }
    }
}
}

struct StoryList: View {
    let sprint: Sprint
    @EnvironmentObject var storyManager: StoryManager

    var body: some View {
        InternalView(sprint: sprint, logic: Logic(storyManager: storyManager))
    }
}

struct StoryList_Previews: PreviewProvider {
    static var previews: some View {
        StoryList(sprint: Sprint.Previews.sprints[0])
            .environmentObject(StoryManager.preview)
    }
}
