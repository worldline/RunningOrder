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
    final class Logic: ObservableObject {
        @Binding var input: String
        private unowned var storyManager: StoryManager
        private unowned var sprintManager: SprintManager
        var searchManager: SearchManager

        init(input: Binding<String>, storyManager: StoryManager, sprintManager: SprintManager, searchManager: SearchManager) {
            self._input = input
            self.storyManager = storyManager
            self.sprintManager = sprintManager
            self.searchManager = searchManager
        }

        /// Return filtered stories
        /// - Parameter filter: user's input
        /// - Returns: All stories in all sprints filtered
        var filteredStories: [Story] {
            var wholeStories: [Story] = []
            sprintManager.sprints.forEach { sprint in
                let storiesPerId = storyManager.stories[sprint.id] ?? []
                wholeStories.append(contentsOf: storiesPerId)
            }

            return wholeStories.filter { story -> Bool in
                return story.name.lowercased().contains(input.lowercased()) || story.epic.lowercased().contains(input.lowercased()) || story.ticketReference.lowercased().contains(input.lowercased())
            }
        }

        var filteredSearchSections: [SearchSection] {
            let formattedStories = filteredStories.map { story -> SearchItem in
                SearchItem(name: "\(story.ticketReference) \(story.name)", icon: SearchSection.SectionType.story.iconName, type: .story, relatedStory: story)
            }

            let filteredEpics = filteredStories.map {
                SearchItem(name: $0.epic, icon: SearchSection.SectionType.epic.iconName, type: SearchSection.SectionType.epic, relatedStory: nil)}

            let sections = [SearchSection(name: SearchSection.SectionType.story.rawValue.uppercased(),
                                          items: formattedStories.removingDuplicates()),
                            SearchSection(name: SearchSection.SectionType.epic.rawValue.uppercased(),
                                          items: filteredEpics.removingDuplicates())]

            return sections
        }
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
