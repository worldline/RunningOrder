//
//  SearchBarSuggestions+Logic.swift
//  RunningOrder
//
//  Created by Ghita Laoud on 26/03/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

extension SearchBarSuggestions {
    enum Scope: CaseIterable {
        case allSprints
        case currentSprint

        var title: LocalizedStringKey {
            switch self {
            case .allSprints:
                return "All Sprints"
            case .currentSprint:
                return "Current Sprint"
            }
        }
    }
    final class Logic: ObservableObject {
        private unowned var storyManager: StoryManager
        private unowned var sprintManager: SprintManager
        private unowned var appStateManager: AppStateManager

        let inputText: String

        @Published var searchScope: Scope = .allSprints

        init(storyManager: StoryManager, sprintManager: SprintManager, appStateManager: AppStateManager, inputText: String) {
            self.storyManager = storyManager
            self.sprintManager = sprintManager
            self.appStateManager = appStateManager
            self.inputText = inputText
        }

        var filteredSearchSections: [SearchSection] {
            guard case .spaceSelected(let space) = appStateManager.currentState else {
                return []
            }

            let allSprints = sprintManager.sprints(for: space.id)
            let selectedSprints: [Sprint.ID]
            switch searchScope {
            case .allSprints:
                selectedSprints = allSprints.map { $0.id }
            case .currentSprint:
                if let first = allSprints.first { // TODO: change this sprint to the selected Sprint
                    selectedSprints = [first.id]
                } else {
                    return []
                }
            }

            let formattedStories = storyManager.allStories(for: selectedSprints)
                .filter {
                    $0.name.lowercased().contains(inputText.lowercased())
                    || $0.epic.lowercased().contains(inputText.lowercased())
                    || $0.ticketReference.lowercased().contains(inputText.lowercased())
                }
                .map { SearchItem.story($0) }

            let filteredEpics = storyManager.epics(for: selectedSprints)
                .map { SearchItem.epic($0) }

            return [
                SearchSection(type: .story, items: Set(formattedStories)),
                SearchSection(type: .epic, items: Set(filteredEpics)),
                SearchSection(type: .filter, items: Set([SearchItem.filter(inputText)]))
            ]
        }
    }
}
