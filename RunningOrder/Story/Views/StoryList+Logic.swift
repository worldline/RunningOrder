//
//  StoryList+Logic.swift
//  RunningOrder
//
//  Created by Clément Nonn on 19/02/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI
import Combine

extension StoryList {
    final class Logic: ObservableObject {
        private var cancellables = Set<AnyCancellable>()
        private unowned var storyManager: StoryManager
        private unowned var searchManager: SearchManager
        private unowned var sprintManager: SprintManager

        @Published var isAddStoryViewDisplayed: Bool = false

        var createdStoryBinding: Binding<Story?> { Binding(callback: self.addStory(_:)) }

        var isSearchFound: Bool {
            searchManager.isItemSelected
        }

        init(storyManager: StoryManager, searchManager: SearchManager, sprintManager: SprintManager) {
            self.storyManager = storyManager
            self.searchManager = searchManager
            self.sprintManager = sprintManager
        }

        private func addStory(_ story: Story) {
            storyManager.add(story: story)
                .ignoreOutput()
                .sink(receiveFailure: { error in Logger.error.log(error) }) // TODO Clean error handling
                .store(in: &cancellables)
        }

        func deleteStory(_ story: Story) {
            self.storyManager.delete(story: story)
        }

        func showAddStoryView() {
            isAddStoryViewDisplayed = true
        }

        func epicColor(for story: Story) -> Color.Identifier {
            let epicIndex = (Array(storyManager.epics).sorted().firstIndex(of: story.epic) ?? 0) % Color.Identifier.epicColors.count

            return Color.Identifier.epicColors[epicIndex]
        }

        var allStories: [Story] {
            var wholeStories: [Story] = []
            sprintManager.sprints.forEach { sprint in
                let storiesPerId = storyManager.stories[sprint.id] ?? []
                wholeStories.append(contentsOf: storiesPerId)
            }

            return wholeStories
        }

        /// Returns the stories of a specific sprintId
        /// - Parameter sprintId: The id of the sprint
        func stories(for sprintId: Sprint.ID, filter: String? = nil) -> [Story] {
            var retrievedStories: [Story]
            retrievedStories = storyManager.stories[sprintId]?.filter { story -> Bool in
                guard let input = filter?.lowercased() else { return true }
                return story.name.lowercased().contains(input) || story.epic.lowercased().contains(input) || story.ticketReference.lowercased().contains(input)
            } ?? []

            if let selectedItem = searchManager.selectedSearchItem {
                switch selectedItem.type {
                case .epic:
                    retrievedStories = allStories.filter { $0.epic == selectedItem.name }
                case .story:
                    if let selectedStory = selectedItem.relatedStory {
                        retrievedStories = [selectedStory]
                    }
                case .people:
                    break
                }
            }

            return retrievedStories
        }
    }
}
