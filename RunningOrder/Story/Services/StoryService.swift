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

    func fetch(from sprintId: Sprint.ID) -> AnyPublisher<[Story], Swift.Error> {
        let reference = CKRecord.Reference(recordID: CKRecord.ID(recordName: sprintId, zoneID: cloudkitContainer.sharedZoneId), action: .deleteSelf)

        // we query the story records of the specific sprintId
        let predicate = NSPredicate(format: "sprintId == %@", reference)
        let query = CKQuery(recordType: RecordType.story.rawValue, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        let fetchOperation = CKQueryOperation(query: query)

        //specific CKRecordZone.ID where to fetch the records
        fetchOperation.zoneID = cloudkitContainer.sharedZoneId

        let configuration = CKOperation.Configuration()
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5

        fetchOperation.configuration = configuration

        cloudkitContainer.currentDatabase.add(fetchOperation)

        return fetchOperation
            .publishers().recordFetched
            .tryMap { try Story.init(from: $0) }
            .collect()
            .eraseToAnyPublisher()
    }

    func save(story: Story) -> AnyPublisher<Story, Swift.Error> {
        let storyRecord = story.encode(zoneId: cloudkitContainer.sharedZoneId)

        let saveOperation = CKModifyRecordsOperation()
        saveOperation.recordsToSave = [storyRecord]

        let configuration = CKOperation.Configuration()
        configuration.qualityOfService = .utility

        saveOperation.configuration = configuration

        cloudkitContainer.currentDatabase.add(saveOperation)

        return saveOperation.publishers().perRecord
            .tryMap { try Story.init(from: $0) }
            .eraseToAnyPublisher()
    }
}
