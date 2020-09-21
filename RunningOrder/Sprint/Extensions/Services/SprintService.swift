//
//  SprintService.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 26/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import Combine
import CloudKit

/// The service responsible of all the Sprint CRUD operation
class SprintService {
    let cloudkitContainer = CloudKitContainer.shared

    func fetchAll(from spaceId: Space.ID) -> AnyPublisher<[Sprint], Swift.Error> {
        let reference = CKRecord.Reference(recordID: CKRecord.ID(recordName: spaceId, zoneID: cloudkitContainer.sharedZoneId), action: .deleteSelf)

        // we query the sprint records of the specific spaceId
        let predicate = NSPredicate(format: "spaceId == %@", reference)

        let query = CKQuery(recordType: RecordType.sprint.rawValue, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        let fetchOperation = CKQueryOperation(query: query)

        // specific CKRecordZone.ID where to fetch the records
        fetchOperation.zoneID = cloudkitContainer.sharedZoneId

        let configuration = CKOperation.Configuration()
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5

        fetchOperation.configuration = configuration

        cloudkitContainer.currentDatabase.add(fetchOperation)

        return fetchOperation
            .publishers().recordFetched
            .tryMap { try Sprint.init(from: $0) }
            .collect()
            .eraseToAnyPublisher()
    }

    func save(sprint: Sprint) -> AnyPublisher<Sprint, Swift.Error> {
        let sprintRecord = sprint.encode(zoneId: cloudkitContainer.sharedZoneId)

        let saveOperation = CKModifyRecordsOperation()
        saveOperation.recordsToSave = [sprintRecord]

        let configuration = CKOperation.Configuration()
        configuration.qualityOfService = .utility

        saveOperation.configuration = configuration

        cloudkitContainer.currentDatabase.add(saveOperation)

        return saveOperation.publishers().perRecord
            .tryMap { try Sprint.init(from: $0) }
            .eraseToAnyPublisher()
    }

}
