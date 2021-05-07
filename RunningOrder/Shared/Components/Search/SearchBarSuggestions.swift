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

    let searchText: String

    var body: some View {
        InternalView(
            logic: Logic(
                inputText: searchText,
                storyManager: storyManager
            )
        )
    }
}

extension SearchBarSuggestions {
    fileprivate struct InternalView: View {
        @ObservedObject var logic: Logic
        @EnvironmentObject var searchManager: SearchManager

        var body: some View {
            ScrollView {
                VStack(alignment: .leading) {
                    if !logic.filteredStories.isEmpty {
                        ForEach(logic.filteredSearchSections, id: \.id) { section in
                            Section(header: Text(section.type.title).font(.headline).bold()) {
                                Divider()

                                ForEach(Array(section.items)) { item in
                                    SuggestionRow(imageName: item.icon, suggestion: item.name)
                                        .onTapGesture { searchManager.selectItem(item) }
                                }
                            }
                        }
                    } else {
                        Spacer()
                        Label("No matching stories, epics found", systemImage: "magnifyingglass")
                            .padding()
                        Spacer()
                    }
                }
                .padding(8)
            }
            .frame(width: 300, height: 300, alignment: .top)
        }
    }
}

struct SearchBarSuggestions_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarSuggestions(searchText: "")
    }
}
