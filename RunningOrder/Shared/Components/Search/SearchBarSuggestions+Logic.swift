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
        private unowned var storyManager: StoryManager
        let inputText: String

        init(inputText: String, storyManager: StoryManager) {
            self.storyManager = storyManager
            self.inputText = inputText
        }

        var filteredStories: [Story] {
            return storyManager.allStories
                .filter {
                    $0.name.lowercased().contains(inputText.lowercased())
                    || $0.epic.lowercased().contains(inputText.lowercased())
                    || $0.ticketReference.lowercased().contains(inputText.lowercased())
                }
        }

        var filteredSearchSections: [SearchSection] {
            let formattedStories = filteredStories.map { story -> SearchItem in
                SearchItem(name: "\(story.name)", icon: SearchSection.SectionType.story.icon, type: .story, relatedStory: story)
            }

            let filteredEpics = filteredStories.map {
                SearchItem(name: $0.epic, icon: SearchSection.SectionType.epic.icon, type: .epic, relatedStory: nil)
            }

            return [
                SearchSection(type: SearchSection.SectionType.story, items: Set(formattedStories)),
                SearchSection(type: SearchSection.SectionType.epic, items: Set(filteredEpics))
            ]
        }
    }
}
