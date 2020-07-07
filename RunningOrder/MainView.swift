//
//  MainView.swift
//  RunningOrder
//
//  Created by Clément Nonn on 23/06/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @State private var selectedSprint: Sprint?

    var storiesBinding: Binding<[Story]> {
        Binding {
            selectedSprint?.stories ?? []
        } set: { newStories in
            selectedSprint?.stories = newStories
        }
    }
    
    var body: some View {
        NavigationView {
            SprintsView(selectedSprint: $selectedSprint)
                .listStyle(SidebarListStyle())

            if selectedSprint != nil {
                HSplitView {
                    StoriesView(stories: storiesBinding)
                        .listStyle(PlainListStyle())
                        .frame(minWidth: 100, maxWidth: 400, maxHeight: .infinity)

                    StoryDetailView().frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .center
                    )
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            idealHeight: 100,
            maxHeight: .infinity,
            alignment: .leading
        )
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
