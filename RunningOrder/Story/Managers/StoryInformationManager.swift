//
//  StoryInformationManager.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 12/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import CloudKit

final class StoryInformationManager: ObservableObject {

    @Published var storyInformations: [Story.ID: StoryInformation] = [:]

    @Published var storyInformationsBuffer: [Story.ID: StoryInformation] = [:]

    @Stored(fileName: "storyInformations.json", directory: .applicationSupportDirectory) private var storedStoryInformations: [StoryInformation]?

    var cancellables: Set<AnyCancellable> = []

    private let service: StoryInformationService

    init(service: StoryInformationService, dataPublisher: AnyPublisher<ChangeInformation, Never>) {
        self.service = service

        if let storedStoryInformations = storedStoryInformations {
            storyInformations = [Story.ID: [StoryInformation]](grouping: storedStoryInformations) { storyInformation in
                storyInformation.storyId
            }
            .mapValues { $0.first! }
        }

        dataPublisher.sink(receiveValue: { [weak self] informations in
            self?.updateData(with: informations.toUpdate)
            self?.deleteData(recordIds: informations.toDelete)
        }).store(in: &cancellables)

        $storyInformations
            .throttle(for: 5, scheduler: DispatchQueue.main, latest: true)
            .map { Array($0.values) }
            .assign(to: \.storedStoryInformations, on: self)
            .store(in: &cancellables)

        // saving storyinformation while live editing in the list component, each modification is stored in the buffer in order to persist it
        // when the saving operation is sent to the cloud, we empty the buffer
        // the throttle is here to reduce the number of operation
        $storyInformationsBuffer
            .filter { !$0.isEmpty }
            .throttle(for: 4.0, scheduler: DispatchQueue.main, latest: true)
            .sink { value in
                self.service.save(storyInformations: Array(value.values))
                    .ignoreOutput()
                    .sink (receiveFailure: { failure in
                        NotificationCenter.default.postError(failure)
                    })
                    .store(in: &self.cancellables)

                self.storyInformationsBuffer.removeAll()
            }
            .store(in: &cancellables)
    }

    func informations(for story: Story) -> Binding<StoryInformation> {
        return Binding {
            self.storyInformations[story.id] ?? StoryInformation(storyId: story.id, zoneId: story.zoneId)
        } set: { newValue in
            self.storyInformations[story.id] = newValue
            self.storyInformationsBuffer[story.id] = newValue
        }
    }

    func updateData(with updatedRecords: [CKRecord]) {
        let updatedStoryInformationArray = updatedRecords
            .compactMap { record -> StoryInformation? in
                do {
                    return try StoryInformation(from: record)
                } catch {
                    Logger.error.log("\(error)\ncaused by \(record)")
                    return nil
                }
            }
            .map { ($0.storyId, $0) }

        let updatedDictionary = [Story.ID: StoryInformation](updatedStoryInformationArray) { _, new in new }
        DispatchQueue.main.async {
            self.storyInformations.merge(updatedDictionary, uniquingKeysWith: { _, new in new })
        }
    }

    func deleteData(recordIds: [CKRecord.ID]) {
        for recordId in recordIds {
            if let existingReference = storyInformations.keys.first(where: { StoryInformation.recordName(for: $0) == recordId.recordName}) {
                storyInformations[existingReference] = nil
            } else {
                Logger.warning.log("storyInformation not found when deleting \(recordId.recordName)")
            }
        }
    }
}

extension StoryInformationManager {
    static let preview = StoryInformationManager(service: StoryInformationService(), dataPublisher: Empty().eraseToAnyPublisher())
}
