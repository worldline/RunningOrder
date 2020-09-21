//
//  StoryInformationService.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 26/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import Combine
import CloudKit

/// The service responsible of all the StoryInformation CRUD operation
class StoryInformationService {
    let cloudkitContainer = CloudKitContainer.shared

    func fetch(from storyId: Story.ID) -> AnyPublisher<StoryInformation, Swift.Error> {
        let reference = CKRecord.Reference(recordID: CKRecord.ID(recordName: storyId, zoneID: cloudkitContainer.sharedZoneId), action: .deleteSelf)

        // we query the storyinformation recordsof the specific storyId
        let predicate = NSPredicate(format: "storyId == %@", reference)
        let query = CKQuery(recordType: RecordType.storyInformation.rawValue, predicate: predicate)

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
            .tryMap { try StoryInformation.init(from: $0) }
            .eraseToAnyPublisher()
    }

    func save(storyInformations: [StoryInformation]) -> AnyPublisher<[StoryInformation], Swift.Error> {
        let storyInformationRecords = storyInformations.map { $0.encode(zoneId: cloudkitContainer.sharedZoneId) }

        let saveOperation = CKModifyRecordsOperation()
        saveOperation.recordsToSave = storyInformationRecords

        let configuration = CKOperation.Configuration()
        configuration.qualityOfService = .utility

        saveOperation.configuration = configuration
        saveOperation.savePolicy = .allKeys // save policy to handle update

        cloudkitContainer.currentDatabase.add(saveOperation)

        return saveOperation.publishers().perRecord
            .tryMap { try StoryInformation.init(from: $0) }
            .collect()
            .eraseToAnyPublisher()
    }
}
