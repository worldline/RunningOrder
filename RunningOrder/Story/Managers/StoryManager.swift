//
//  StoryManager.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 12/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI
import Combine

///The class responsible of managing the Story data, this is the only source of truth
final class StoryManager: ObservableObject {

    @Published var stories: [Sprint.ID: [Story]] = [:]

    var cancellables: Set<AnyCancellable> = []

    private let service: StoryService

    init(service: StoryService) {
        self.service = service
    }

    /// Returns the stories of a specific sprintId
    /// - Parameter sprintId: The id of the sprint
    func stories(for sprintId: Sprint.ID) -> [Story] {
        // if we have already fetched in the cloud no need to fetch again
        if let sprintStories = stories[sprintId] {
            return sprintStories
        } else {
            service.fetch(from: sprintId)
                .catchAndExit { error in print(error) } // TODO Error Handling
                .receive(on: DispatchQueue.main)
                .assign(to: \.stories[sprintId], onStrong: self)
                .store(in: &cancellables)

            // we return an empty array while the data is fetched in background, the UI will be updated when the task is done
            return []
        }
    }

    func add(story: Story) -> AnyPublisher<Story, Error> {
        let saveStoryPublisher = service.save(story: story)
            .share()
            .receive(on: DispatchQueue.main)

        saveStoryPublisher
            .catchAndExit { _ in } // we do nothing if an error occurred
            .append(to: \.stories[story.sprintId], onStrong: self) // we add append the Story Output to the Story array associates with sprintId
            .store(in: &cancellables)

        return saveStoryPublisher.eraseToAnyPublisher()
    }
}
