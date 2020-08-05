//
//  SprintDetail.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 05/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct SprintDetail: View {

    var sprint: Sprint
    @ObservedObject private var viewModel: SprintDetailViewModel
    @EnvironmentObject var toolbarManager: ToolbarManager

    init(sprint: Sprint) {
        self.sprint = sprint
        viewModel = SprintDetailViewModel(sprint: sprint)
    }
    var body: some View {

            NavigationView {
                StoryList(header: "Sprint \(sprint.number) - \(sprint.name)", stories: $viewModel.stories) // TODO Construct/Pass the head in a different way ?
                    .onAppear {
                        viewModel.fetchStories()
                    }
                Text("Select a Story")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .sheet(isPresented: $toolbarManager.isAddStoryButtonClicked) {
                NewStoryView(sprint: sprint, createdStory: $viewModel.stories.appendedElement)
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

struct SprintDetail_Previews: PreviewProvider {
    static var previews: some View {
        SprintDetail(sprint: Sprint.Previews.sprints[0])
    }
}
