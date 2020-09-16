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

class StoryInformationService {
    let cloudkitContainer = CloudKitContainer.shared

    func fetch(from storyId: Story.ID) -> AnyPublisher<StoryInformation, Swift.Error> {
        let reference = CKRecord.Reference(recordID: CKRecord.ID(recordName: storyId, zoneID: cloudkitContainer.sharedZoneId), action: .deleteSelf)
        let predicate = NSPredicate(format: "storyId == %@", reference)
        let query = CKQuery(recordType: RecordType.storyInformation.rawValue, predicate: predicate)

        let fetchOperation = CKQueryOperation(query: query)

        fetchOperation.zoneID = cloudkitContainer.sharedZoneId

        let configuration = CKOperation.Configuration()
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5

        fetchOperation.configuration = configuration

        cloudkitContainer.container.privateCloudDatabase.add(fetchOperation)

        return fetchOperation
            .recordFetchedPublisher()
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

        cloudkitContainer.container.privateCloudDatabase.add(saveOperation)

        return saveOperation.perRecordPublisher()
            .tryMap { try StoryInformation.init(from: $0) }
            .collect()
            .eraseToAnyPublisher()
    }
}
