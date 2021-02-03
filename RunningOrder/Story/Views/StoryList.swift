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
    @State private var isAddStoryViewDisplayed: Bool = false

    @EnvironmentObject var storyManager: StoryManager
    @EnvironmentObject var storyInformationManager: StoryInformationManager

    private let disposeBag = DisposeBag()
    @State private var selected: Story?

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
        List(storyManager.stories(for: sprint.id), id: \.self, selection: $selected) { story in
            VStack {
                NavigationLink(
                    destination: StoryDetail(story: story),
                    label: { StoryRow(story: story) }
                )
                .contextMenu {
                    Button(
                        action: { self.storyManager.delete(story: story) },
                        label: { Text("Delete Story") }
                    )
                }

                if story == selected {
                    Divider()
                        .hidden()
                } else {
                    Divider()
                }
            }
        }
        .navigationTitle("Sprint \(sprint.number) - \(sprint.name)")
        .frame(minWidth: 100, idealWidth: 300)
        .toolbar {
            ToolbarItems.sidebarItem

            ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
                Button {
                    self.isAddStoryViewDisplayed = true
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .sheet(isPresented: $isAddStoryViewDisplayed) {
            NewStoryView(sprintId: sprint.id, createdStory: createdStoryBinding)
        }
    }

    func addStory(story: Story) {
        storyManager.add(story: story)
            .ignoreOutput()
            .sink(receiveFailure: { error in Logger.error.log(error) }) // TODO Clean error handling
            .store(in: &disposeBag.cancellables)
    }
}

struct StoryList_Previews: PreviewProvider {
    static var previews: some View {
        StoryList(sprint: Sprint.Previews.sprints[0])
            .environmentObject(StoryManager(service: StoryService(), dataPublisher: changeInformationPreview))
    }
}
