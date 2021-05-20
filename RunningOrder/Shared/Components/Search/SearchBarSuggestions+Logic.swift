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
        private unowned var userManager: UserManager

        let inputText: String

        @Published var searchScope: Scope = .allSprints

        init(storyManager: StoryManager, sprintManager: SprintManager, appStateManager: AppStateManager, userManager: UserManager, inputText: String) {
            self.storyManager = storyManager
            self.sprintManager = sprintManager
            self.appStateManager = appStateManager
            self.userManager = userManager
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

            var searchSections = [SearchSection]()

            let formattedStories = storyManager.allStories(for: selectedSprints)
                .filter {
                    $0.name.contains(inputText, options: .caseInsensitive)
                    || $0.epic.contains(inputText, options: .caseInsensitive)
                    || $0.ticketReference.contains(inputText, options: .caseInsensitive)
                }
                .map { SearchItem.story($0) }

            if !formattedStories.isEmpty {
                searchSections.append(SearchSection(type: .story, items: Set(formattedStories)))
            }

            let filteredEpics = storyManager.epics(for: selectedSprints)
                .filter { $0.contains(inputText, options: .caseInsensitive) }
                .map { SearchItem.epic($0) }

            if !filteredEpics.isEmpty {
                searchSections.append(SearchSection(type: .epic, items: Set(filteredEpics)))
            }

            let peopleItems = userManager.users
                .filter { $0.identity.name?.contains(inputText, options: .caseInsensitive) ?? false }
                .map { SearchItem.people($0) }

            if !peopleItems.isEmpty {
                searchSections.append(SearchSection(type: .people, items: Set(peopleItems)))
            }

            searchSections.append(SearchSection(type: .filter, items: Set([SearchItem.filter(inputText)])))

            return searchSections
        }
    }
}

extension String {
    func contains(_ string: String, options: CompareOptions) -> Bool {
        return self.range(of: string, options: options) != nil
    }
}
