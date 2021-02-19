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

    var cancellables: Set<AnyCancellable> = []

    private let service: StoryInformationService

    init(service: StoryInformationService, dataPublisher: AnyPublisher<ChangeInformation, Never>) {
        self.service = service

        dataPublisher.sink(receiveValue: { [weak self] informations in
            self?.updateData(with: informations.toUpdate)
            self?.deleteData(recordIds: informations.toDelete)
        }).store(in: &cancellables)

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
                        Logger.error.log(failure) // TODO error Handling
                    })
                    .store(in: &self.cancellables)

                self.storyInformationsBuffer.removeAll()
            }
            .store(in: &cancellables)
    }

    func informations(for storyId: Story.ID) -> Binding<StoryInformation> {
        return Binding {
            self.storyInformations[storyId] ?? StoryInformation(storyId: storyId)
        } set: { newValue in
            self.storyInformations[storyId] = newValue
            self.storyInformationsBuffer[storyId] = newValue
        }
    }

    func updateData(with updatedRecords: [CKRecord]) {
        do {
            let updatedStoryInformationArray = try updatedRecords
                .map(StoryInformation.init(from:))
                .map { ($0.storyId, $0) }

            let updatedDictionary = [Story.ID: StoryInformation](updatedStoryInformationArray) { _, new in new }
            DispatchQueue.main.async {
                self.storyInformations.merge(updatedDictionary, uniquingKeysWith: { _, new in new })
            }

        } catch {
            Logger.error.log(error)
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
