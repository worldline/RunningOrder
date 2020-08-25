//
//  StoryManager.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 12/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI
import Combine

final class StoryService {
    var stories: [Story] = []
}

final class StoryManager: ObservableObject {
    private let service = StoryService()

    @Published var stories: [Sprint.ID: [Story]] = [:]

    var cancellables: Set<AnyCancellable> = []

    private let cloudkitManager = CloudKitManager()

    func stories(for sprintId: Sprint.ID) -> [Story] {
        if let sprintStories = stories[sprintId] {
            return sprintStories
        } else {
            cloudkitManager.fetchStories(from: sprintId)
                .catchAndExit { error in print(error) } // TODO Error Handling
                .receive(on: DispatchQueue.main)
                .assign(to: \.stories[sprintId], onStrong: self)
                .store(in: &cancellables)

            // we return an empty array while the data is fetched in background, the UI will be updated when the task is done
            return []
        }
    }

    func add(story: Story) -> AnyPublisher<[Story], Error> {
        let saveStoryPublisher = cloudkitManager.save(story: story)
            .tryMap { (savedStory: Story) -> [Story] in
                guard var newStories = self.stories[story.sprintId] else { throw CloudKitManager.Error.recordFailure}
                newStories.append(savedStory)
                return newStories
            }
            .share()
            .receive(on: DispatchQueue.main)

        saveStoryPublisher
            .catchAndExit { _ in }
            .assign(to: \.stories[story.sprintId], onStrong: self)
            .store(in: &cancellables)

        return saveStoryPublisher.eraseToAnyPublisher()
    }
}
