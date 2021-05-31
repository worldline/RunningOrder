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
    @EnvironmentObject var appStateManager: AppStateManager

    let searchText: String

    var body: some View {
        InternalView(
            logic: Logic(
                storyManager: storyManager,
                sprintManager: sprintManager,
                appStateManager: appStateManager,
                inputText: searchText
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
//                Picker("Search Scope", selection: $logic.searchScope) {
//                    ForEach(Scope.allCases, id: \.self) { scope in
//                        Text(scope.title)
//                            .tag(scope)
//                    }
//                }
//                .labelsHidden()
//                .pickerStyle(SegmentedPickerStyle())
//                .padding()

                VStack(alignment: .leading) {
                    ForEach(logic.filteredSearchSections) { section in
                        Section(header: header(section.type.title)) {
                            Divider()

                            ForEach(Array(section.items)) { item in
                                SuggestionRow(imageName: section.type.icon, suggestion: item.name)
                                    .onTapGesture { searchManager.selectItem(item) }
                            }
                        }
                    }
                }
                .padding(8)
            }
            .frame(width: 300, height: 300, alignment: .top)
        }

        func header(_ string: String) -> some View {
            Text(string)
                .font(.headline)
                .bold()
        }
    }
}

struct SearchBarSuggestions_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarSuggestions(searchText: "")
    }
}
