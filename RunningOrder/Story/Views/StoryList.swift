//
//  StoryList.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

extension Story: Identifiable {}

struct StoryList: View {

    let sprint: Sprint

    @EnvironmentObject var toolbarManager: ToolbarManager

    @EnvironmentObject var storyManager: StoryManager
    @EnvironmentObject var storyInformationManager: StoryInformationManager

    private let disposeBag = DisposeBag()

    var createdStoryBinding: Binding<Story?> {
        return Binding<Story?>(
            get: { return nil },
            set: { newValue in
                if let story = newValue {
                    self.addStory(story: story)
                }
            }
        )
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Sprint \(sprint.number) - \(sprint.name)")
                    .font(.headline)
                    .padding(13)
                List {
                    Divider()

                    ForEach(storyManager.stories(for: sprint.id), id: \.self) { story in
                        NavigationLink(
                            destination: StoryDetail(story: story).environmentObject(storyInformationManager),
                            label: { StoryRow(story: story) }
                        )
                        Divider()
                    }
                }
                .colorMultiply(Color("concrete"))
            }
            .background(Color("concrete"))

            .frame(minWidth: 100, maxWidth: 400)

            Text("Select a Story")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
        }
        .sheet(isPresented: $toolbarManager.isAddStoryButtonClicked) {
            NewStoryView(sprintId: sprint.id, createdStory: createdStoryBinding)
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

    func addStory(story: Story) {
        storyManager.add(story: story)
            .catchAndExit { error in print(error) } // TODO Clean error handling
            .sink { _ in }
            .store(in: &disposeBag.cancellables)
    }
}

struct StoryList_Previews: PreviewProvider {
    static var previews: some View {
        StoryList(sprint: Sprint.Previews.sprints[0])
            .environmentObject(StoryManager(service: StoryService()))
    }
}
