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
        unowned var searchManager: SearchManager

        init(input: Binding<String>, storyManager: StoryManager, searchManager: SearchManager) {
            self._input = input
            self.storyManager = storyManager
            self.searchManager = searchManager
        }

        var filteredStories: [Story] {
            let stories = storyManager.allStories.filter {$0.name.lowercased().contains(input.lowercased()) || $0.epic.lowercased().contains(input.lowercased()) || $0.ticketReference.lowercased().contains(input.lowercased())
            }

            return stories
        }

        var filteredSearchSections: [SearchSection] {
            let formattedStories = filteredStories.map { story -> SearchItem in
                SearchItem(name: "\(story.ticketReference) \(story.name)", icon: SearchSection.SectionType.story.icon, type: .story, relatedStory: story)
            }

            let filteredEpics = filteredStories.map {
                SearchItem(name: $0.epic, icon: SearchSection.SectionType.epic.icon, type: .epic, relatedStory: nil)
            }

            let sections = [SearchSection(type: SearchSection.SectionType.story, items: Set(formattedStories)),
                            SearchSection(type: SearchSection.SectionType.epic, items: Set(filteredEpics))]

            return sections
        }
    }
}
