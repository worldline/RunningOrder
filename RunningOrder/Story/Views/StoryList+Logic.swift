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

        @Published var isAddStoryViewDisplayed: Bool = false

        var createdStoryBinding: Binding<Story?> { Binding(callback: self.addStory(_:)) }
        let sprint: Sprint

        var navigationTitle: LocalizedStringKey {
            if let selectedItem = searchManager.selectedSearchItem {
                switch selectedItem {
                case .epic(let epic):
                    return "EPIC \"\(epic)\""
                case .filter(let filterString):
                    return "Filtering \"\(filterString)\""
                case .story(_):
                    return "Sprint \(sprint.number) - \(sprint.name)"
                case .people(let user):
                    return "De \(user.identity.name ?? "Nobody")"
                }
            } else {
                return "Sprint \(sprint.number) - \(sprint.name)"
            }
        }

        init(storyManager: StoryManager, searchManager: SearchManager, sprint: Sprint) {
            self.storyManager = storyManager
            self.searchManager = searchManager
            self.sprint = sprint
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
    }
}
