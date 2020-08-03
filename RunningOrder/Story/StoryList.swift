//
//  StoryList.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

extension Story: Identifiable {
    var id: String { ticketReference }
}

struct StoryList: View {
    let header: String
    @Binding var stories: [Story]
    @EnvironmentObject var toolbarManager: ToolbarManager

    var body: some View {
        NavigationView {
            List {
                Section(header: Text(header).font(.headline )) {
                    ForEach(stories) { story in
                        NavigationLink(
                            destination: StoryDetail(story: story),
                            label: {
                                StoryRow(story: story)
                            })
                    }
                }
            }
            .frame(minWidth: 100, maxWidth: 200, maxHeight: .infinity)

            Text("Select a Story")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .sheet(isPresented: $toolbarManager.isAddStoryButtonClicked) {
            NewStoryView(createdStory: self.$stories.appendedElement)
        }
        .onAppear {
            // enabling toolbar add story button
            toolbarManager.isASprintSelected = true
        }
        .onDisappear {
            // disabling toolbar add story button
            toolbarManager.isASprintSelected = false
        }
    }
}

struct StoryList_Previews: PreviewProvider {
    static var previews: some View {
        StoryList(header: "Sprint 66 - HelloBank", stories: .constant(Story.Previews.stories))
    }
}
