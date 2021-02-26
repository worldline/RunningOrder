//
//  StoryList+Logic.swift
//  RunningOrder
//
//  Created by Clément Nonn on 19/02/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI
import Combine

extension StoryList {
    final class Logic: ObservableObject {
        private var cancellables = Set<AnyCancellable>()
        private unowned var storyManager: StoryManager

        @Published var isAddStoryViewDisplayed: Bool = false

        var createdStoryBinding: Binding<Story?> {
            return Binding<Story?>(
                get: { return nil },
                set: { newValue in
                    if let story = newValue {
                        self.addStory(story)
                    }
                }
            )
        }

        init(storyManager: StoryManager) {
            self.storyManager = storyManager
        }

        private func addStory(_ story: Story) {
            storyManager.add(story: story)
                .ignoreOutput()
                .sink(receiveFailure: { error in Logger.error.log(error) }) // TODO Clean error handling
                .store(in: &cancellables)
        }

        func deleteStory(_ story: Story) {
            self.storyManager.delete(story: story)
        }

        func showAddStoryView() {
            isAddStoryViewDisplayed = true
        }

        func epicColor(for story: Story) -> Color.Identifier {
            let epicIndex = (Array(storyManager.epics).sorted().firstIndex(of: story.epic) ?? 0) % Color.Identifier.epicColors.count

            return Color.Identifier.epicColors[epicIndex]
        }
    }
}
