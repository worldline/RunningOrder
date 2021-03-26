//
//  SearchBarSuggestions.swift
//  RunningOrder
//
//  Created by Ghita Laoud on 25/03/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI

struct SearchBarSuggestions: View {
    @Binding var input: String
    @EnvironmentObject var storyManager: StoryManager
    @EnvironmentObject var sprintManager: SprintManager

    func stories(filter: String) -> [Story] {
        var wholeStories: [Story] = []
        for sprint in sprintManager.sprints {
            let storiesPerId = storyManager.stories[sprint.id] ?? []
            wholeStories.append(contentsOf: storiesPerId)
        }

        return wholeStories.filter { story -> Bool in
            let input = filter.lowercased()
            return story.name.lowercased().contains(input) || story.epic.lowercased().contains(input) || story.ticketReference.lowercased().contains(input)
        }
    }

    var body: some View {
            // Search in specific sprint
            let allStories = stories(filter: input.lowercased())
            let formattedStories = allStories.compactMap {"\($0.ticketReference) \($0.name)"}.map { SearchItem(name: $0, icon: SearchSection.Name.story.iconName)}

            let filteredEpics = allStories.compactMap {"\($0.epic)"}.map {
                SearchItem(name: $0, icon: SearchSection.Name.epic.iconName)}

            let sections = [SearchSection(name: SearchSection.Name.story.rawValue.uppercased(),
                                          items: formattedStories),
                            SearchSection(name: SearchSection.Name.epic.rawValue.uppercased(),
                                          items: filteredEpics)]
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(sections, id: \.id) { section in
                    Section(header: Text(section.name).font(.headline).bold()) {
                            Group {
                                ForEach(section.items) { item in
                                    SuggestionRow(imageName: item.icon, suggestion: item.name)
                                }
                            }
                        }
                    }
            }.padding(8)
        }.frame(width: 300, height: 300)
    }
}

struct SearchBarSuggestions_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarSuggestions(input: .constant(""))
    }
}
