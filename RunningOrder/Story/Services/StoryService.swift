//
//  StoryService.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 26/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import Combine
import CloudKit

/// The service responsible of all the Story CRUD operation
class StoryService {
    let cloudkitContainer = CloudKitContainer.shared

    func save(story: Story) -> AnyPublisher<Story, Swift.Error> {
        let storyRecord = story.encode()

        let saveOperation = CKModifyRecordsOperation()
        saveOperation.recordsToSave = [storyRecord]

        let configuration = CKOperation.Configuration()
        configuration.qualityOfService = .utility

        saveOperation.configuration = configuration

        cloudkitContainer.database(for: story.zoneId).add(saveOperation)

        return saveOperation.publishers().perRecord
            .tryMap { try Story.init(from: $0) }
            .eraseToAnyPublisher()
    }

    func delete(story: Story) -> AnyPublisher<Never, Swift.Error> {
        let record = story.encode()
        let deleteOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [record.recordID])

        let configuration = CKOperation.Configuration()
        configuration.qualityOfService = .utility

        deleteOperation.configuration = configuration

        cloudkitContainer.database(for: story.zoneId).add(deleteOperation)

        return deleteOperation.publishers()
            .completion
            .ignoreOutput()
            .eraseToAnyPublisher()
    }
}
