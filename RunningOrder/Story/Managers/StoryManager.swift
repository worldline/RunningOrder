//
//  StoryManager.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 12/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI
import Combine
import CloudKit

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
        return stories[sprintId] ?? []
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

    func updateData(with updatedRecords: [CKRecord]) {
        do {
            let updatedStories = try updatedRecords.map(Story.init(from:))

            for story in updatedStories {
                if let index = stories[story.sprintId]?.firstIndex(where: { $0.id == story.id }) {
                    stories[story.sprintId]?[index] = story
                } else {
                    Logger.warning.log("story with id \(story.id) not found, so appending it to existing story list")
                    if stories.index(forKey: story.sprintId) == nil {
                        stories[story.sprintId] = [story]
                    } else {
                        stories[story.sprintId]?.append(story)
                    }
                }
            }
        } catch {
            Logger.error.log(error)
        }
    }

    private func findExistingStory(for recordId: CKRecord.ID) -> (sprintId: Sprint.ID, index: Int)? {
        for (sprintId, stories) in stories {
            if let index = stories.firstIndex(where: { $0.id == recordId.recordName }) {
                return (sprintId, index)
            }
        }

        return nil
    }

    func deleteData(recordIds: [CKRecord.ID]) {
        for recordId in recordIds {
            if let existingReference = findExistingStory(for: recordId) {
                stories[existingReference.sprintId]!.remove(at: existingReference.index)
            } else {
                Logger.warning.log("story not found when deleting \(recordId.recordName)")
            }
        }
    }
}
