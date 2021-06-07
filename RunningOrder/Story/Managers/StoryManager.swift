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
    @Stored(fileName: "stories.json", directory: .applicationSupportDirectory) private var storedStories: [Story]?

    var epics: Set<String> {
        return stories
            .values
            .reduce(Set<String>()) { result, values in
                result.union(values.map { $0.epic })
            }
    }

    var cancellables: Set<AnyCancellable> = []

    private let service: StoryService
    private let userService: UserService

    init(service: StoryService, userService: UserService, dataPublisher: AnyPublisher<ChangeInformation, Never>) {
        self.service = service
        self.userService = userService

        if let storedStories = storedStories {
            stories = [Sprint.ID: [Story]](grouping: storedStories) { story in
                story.sprintId
            }
        }

        dataPublisher.sink(receiveValue: { [weak self] informations in
            self?.updateData(with: informations.toUpdate)
            self?.deleteData(recordIds: informations.toDelete)
        }).store(in: &cancellables)

        $stories
            .throttle(for: 5, scheduler: DispatchQueue.main, latest: true)
            .map { stories in Array(stories.values).flatMap { $0 } }
            .assign(to: \.storedStories, on: self)
            .store(in: &cancellables)
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
            let updatedStories = try updatedRecords
                .sorted(by: { ($0.creationDate ?? Date()) < ($1.creationDate ?? Date()) })
                .map(Story.init(from:))

            var currentStories = self.stories
            for story in updatedStories {
                if let index = currentStories[story.sprintId]?.firstIndex(where: { $0.id == story.id }) {
                    currentStories[story.sprintId]?[index] = story
                } else {
                    Logger.warning.log("story with id \(story.id) not found, so appending it to existing story list")
                    if currentStories.index(forKey: story.sprintId) == nil {
                        currentStories[story.sprintId] = [story]
                    } else {
                        currentStories[story.sprintId]?.append(story)
                    }
                }
            }
            DispatchQueue.main.async {
                self.stories = currentStories
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

    func getUser(creatorOf story: Story) -> AnyPublisher<User, Error> {
        guard let reference = story.creatorReference else {
            return Fail(outputType: User.self, failure: BasicError.noValue).eraseToAnyPublisher()
        }

        return userService
            .fetch(userReference: reference)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func delete(story: Story) {
        guard let (sprintId, index) = findExistingStory(for: CKRecord.ID(recordName: story.id)) else {
            Logger.error.log("couldn't find index of story in stored stories")
            return
        }

        service.delete(story: story)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    Logger.error.log(error) // TODO: error Handling
                case .finished:
                    self?.stories[sprintId]?.remove(at: index)
                    if self?.stories[sprintId]?.isEmpty ?? false {
                        self?.stories.removeValue(forKey: sprintId)
                    }
                }
            })
            .store(in: &cancellables)
    }

    func deleteData(recordIds: [CKRecord.ID]) {
        for recordId in recordIds {
            if let existingReference = findExistingStory(for: recordId) {
                DispatchQueue.main.async {
                    self.stories[existingReference.sprintId]!.remove(at: existingReference.index)
                }
            } else {
                Logger.warning.log("story not found when deleting \(recordId.recordName)")
            }
        }
    }

    func allStories(for sprints: [Sprint.ID]) -> [Story] {
        return stories
            .filter { key, value in sprints.contains(key)}
            .flatMap { $1 }
    }

    func epics(for sprints: [Sprint.ID]) -> Set<String> {
        return stories
            .filter { key, value in sprints.contains(key)}
            .values
            .reduce(Set<String>()) { result, values in
                result.union(values.map { $0.epic })
            }
    }

    /// Returns the stories of a specific sprintId, in case of selected searchItem move to search mode
    /// - Parameter sprintId: The id of the sprint
    /// - Parameter searchItem: potential search item
    /// - Returns: Retrieved stories
    func stories(for sprintId: Sprint.ID, searchItem: SearchItem? = nil) -> [Story] {
        if let selectedItem = searchItem {
            switch selectedItem {
            case .epic(let epicString):
                return allStories(for: [sprintId]).filter { $0.epic == epicString }
            case .story(_):
                return allStories(for: [sprintId]) // we show all stories since we just want to go to this story, not only have one item in the list
            case .filter(let filterString):
                return allStories(for: [sprintId])
                    .filter {
                        $0.name.lowercased().contains(filterString.lowercased())
                        || $0.epic.lowercased().contains(filterString.lowercased())
                        || $0.ticketReference.lowercased().contains(filterString.lowercased())
                    }

            case .people(let user):
                return allStories(for: [sprintId])
                    .filter { $0.creatorReference == user.reference }
            }
        } else {
            return allStories(for: [sprintId])
        }
    }
}

extension StoryManager {
    static let preview = StoryManager(service: StoryService(), userService: UserService(), dataPublisher: Empty().eraseToAnyPublisher())
}
