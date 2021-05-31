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
        @EnvironmentObject var searchManager: SearchManager
        @State private var selected: Story?
        @State private var toBeDeletedStory: Story?

        var body: some View {
            List(storyManager.stories(for: sprint.id, searchItem: searchManager.selectedSearchItem), id: \.self, selection: $selected) { story in
                VStack {
                    NavigationLink(
                        destination: StoryDetail(story: story)
                            .epicColor(Color(identifier: logic.epicColor(for: story))),
                        tag: story,
                        selection: $selected,
                        label: { StoryRow(story: story) }
                    )
                    .contextMenu {
                        Button(action: { toBeDeletedStory = story }) {
                            Text("Delete Story")
                        }
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
            .navigationTitle(logic.navigationTitle)
            .frame(minWidth: 100, idealWidth: 300)
            .toolbar {
                ToolbarItems.sidebarItem

                ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
                    Button(action: logic.showAddStoryView) {
                        Image(systemName: "square.and.pencil")
                    }
                    .keyboardShortcut(KeyEquivalent("n"), modifiers: [.command, .shift])

                }
            }
            .sheet(isPresented: $logic.isAddStoryViewDisplayed) {
                NewStoryView(sprint: sprint, createdStory: logic.createdStoryBinding)
            }
            .alert(item: $toBeDeletedStory) { story in
                Alert(
                    title: Text("Delete the story \"\(story.name)\" ?"),
                    message: Text("You can't undo this action."),
                    primaryButton: .destructive(Text("Yes"), action: { logic.deleteStory(story) }),
                    secondaryButton: .cancel()
                )
            }
            .onReceive(searchManager.$selectedSearchItem) { item in
                if case .story(let story) = item {
                    selected = story
                    searchManager.selectedSearchItem = nil
                }
            }
        }
    }
}

struct StoryList: View {
    let sprint: Sprint
    @EnvironmentObject var storyManager: StoryManager
    @EnvironmentObject var searchManager: SearchManager

    var body: some View {
        InternalView(sprint: sprint, logic: Logic(storyManager: storyManager, searchManager: searchManager, sprint: sprint))
    }
}

struct StoryList_Previews: PreviewProvider {
    static var previews: some View {
        StoryList(sprint: Sprint.Previews.sprints[0])
            .environmentObject(StoryManager.preview)
            .environmentObject(SearchManager.preview)
    }
}
