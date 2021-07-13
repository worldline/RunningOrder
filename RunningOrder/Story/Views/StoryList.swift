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

                    Divider()
                        .opacity(story == selected ? 0 : 1)
                }
            }
            .navigationTitle(logic.navigationTitle)
            .frame(minWidth: 100, idealWidth: 300)
            .toolbar {
                ToolbarItems.sidebarItem

                ToolbarItemGroup(placement: ToolbarItemPlacement.cancellationAction) {
                    SortMenu(selectedSort: .constant(SortMenu.Option(type: .name, isReversed: false)))

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

struct SortMenu: View {
    struct Option {
        enum OptionType: String, CaseIterable {
            case epic, name

            var title: LocalizedStringKey {
                switch self {
                case .epic:
                    return "Epic"
                case .name:
                    return "Name"
                }
            }
        }
        var type: OptionType
        var isReversed: Bool

        func apply(lhs: Story, rhs: Story) -> Bool {
            switch (self.type, isReversed) {
            case (.epic, false):
                return lhs.epic < rhs.epic
            case (.epic, true):
                return lhs.epic > rhs.epic
            case (.name, false):
                return lhs.name < rhs.name
            case (.name, true):
                return lhs.name > rhs.name
            }
        }
    }

    @Binding var selectedSort: Option

    func newIsReversed(for optionType: Option.OptionType) -> Bool {
        return optionType == selectedSort.type && !selectedSort.isReversed
    }

    var body: some View {
        Menu {
            ForEach(Option.OptionType.allCases, id: \.rawValue) { optionType in
                Button {
                    selectedSort = Option(type: optionType, isReversed: newIsReversed(for: optionType))
                } label: {
                    Label(optionType.title, systemImage: optionType == selectedSort.type ? "checkmark" : "")
                }
            }
        } label: {
            Image(systemName: "line.horizontal.3.decrease.circle")
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
