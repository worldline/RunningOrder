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

    func stories(for sprintId: Sprint.ID) -> [Story] {
        if let sprintStories = stories[sprintId] {
            return sprintStories
        } else {
            let fetched = service.stories.filter { $0.sprintId == sprintId }
            stories[sprintId] = fetched
            return fetched
        }
    }

    func add(story: Story, toSprint sprintId: Sprint.ID) {
        if var currentStories = stories[sprintId] {
            currentStories.append(story)
            stories[sprintId] = currentStories
        }
    }
}
