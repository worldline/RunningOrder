//
//  SearchBarSuggestions.swift
//  RunningOrder
//
//  Created by Ghita Laoud on 25/03/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI

struct SearchBarSuggestions: View {
    @EnvironmentObject var storyManager: StoryManager
    @EnvironmentObject var sprintManager: SprintManager
    @EnvironmentObject var searchManager: SearchManager

    @Binding var searchText: String
    var body: some View {
        InternalView(logic: Logic(input: $searchText, storyManager: storyManager, sprintManager: sprintManager, searchManager: searchManager))
    }
}

extension SearchBarSuggestions {
    fileprivate struct InternalView: View {
        @ObservedObject var logic: Logic

        var body: some View {
            ScrollView {
                VStack(alignment: .leading) {
                    if !logic.filteredStories.isEmpty {
                        ForEach(logic.filteredSearchSections, id: \.id) { section in
                            Section(header: Text(section.name).font(.headline).bold()) {
                                ForEach(section.items) { item in
                                    SuggestionRow(imageName: item.icon, suggestion: item.name)
                                        .onTapGesture {
                                            logic.searchManager.selectedSearchItem = item
                                        }
                                }
                            }
                        }
                    } else {
                        Label("No matching stories, epics found", systemImage: "magnifyingglass")
                            .padding()
                    }
                }.padding(8)
            }.frame(width: 300, height: 300)
        }
    }
}

struct SearchBarSuggestions_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarSuggestions(searchText: .constant(""))
    }
}
