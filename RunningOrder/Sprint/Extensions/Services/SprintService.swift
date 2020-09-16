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

    func fetchAll() -> AnyPublisher<[Sprint], Swift.Error> {

        // we query all the records
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: RecordType.sprint.rawValue, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        let fetchOperation = CKQueryOperation(query: query)

        //specific CKRecordZone.ID where to fetch the records
        fetchOperation.zoneID = cloudkitContainer.sharedZoneId

        let configuration = CKOperation.Configuration()
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5

        fetchOperation.configuration = configuration

        cloudkitContainer.container.privateCloudDatabase.add(fetchOperation)

        return fetchOperation
            .recordFetchedPublisher()
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

        cloudkitContainer.container.privateCloudDatabase.add(saveOperation)

        return saveOperation.perRecordPublisher()
            .tryMap { try Sprint.init(from: $0) }
            .eraseToAnyPublisher()
    }

}
