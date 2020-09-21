//
//  SpaceService.swift
//  RunningOrder
//
//  Created by Clément Nonn on 21/09/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import Combine
import CloudKit

/// The service responsible of all the Sprint CRUD operation
class SpaceService {
    let cloudkitContainer = CloudKitContainer.shared

    func fetchShared(_ id: CKRecord.ID) -> AnyPublisher<Space, Swift.Error> {
        let operation = CKFetchRecordsOperation(recordIDs: [id])
        cloudkitContainer.container.sharedCloudDatabase.add(operation)

        return operation.publishers()
            .perRecord
            .tryMap { result -> Space in
                if let record = result.0 {
                    return Space(underlyingRecord: record)
                } else {
                    throw SpaceManager.Error.noSpaceAvailable
                }
            }.eraseToAnyPublisher()
    }

    func fetch() -> AnyPublisher<Space, Swift.Error> {

        // we query all the records
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: RecordType.space.rawValue, predicate: predicate)

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
            .map { Space(underlyingRecord: $0) }
            .first()
            .eraseToAnyPublisher()
    }

    func save(space: Space) -> AnyPublisher<Space, Swift.Error> {
        let saveOperation = CKModifyRecordsOperation()
        saveOperation.recordsToSave = [space.underlyingRecord]

        let configuration = CKOperation.Configuration()
        configuration.qualityOfService = .utility

        saveOperation.configuration = configuration

        cloudkitContainer.currentDatabase.add(saveOperation)

        return saveOperation.publishers().perRecord
            .tryMap { Space(underlyingRecord: $0) }
            .eraseToAnyPublisher()
    }

    func getShare(for space: Space) -> AnyPublisher<CKShare, Swift.Error> {
        guard let existingShareReference = space.underlyingRecord.share else {
            fatalError("this call shouldn't be done without verfying the share optionality")
        }

        let operation = CKFetchRecordsOperation(recordIDs: [existingShareReference.recordID])
        cloudkitContainer.currentDatabase.add(operation)
        return operation.publishers()
            .completion
            .compactMap { $0?[existingShareReference.recordID] as? CKShare }
            .eraseToAnyPublisher()
    }

    func saveAndShare(space: Space) -> AnyPublisher<CKShare, Swift.Error> {
        let share = CKShare(rootRecord: space.underlyingRecord)
        share[CKShare.SystemFieldKey.title] = space.name
//        share[CKShare.SystemFieldKey.thumbnailImageData] =

        let saveOperation = CKModifyRecordsOperation()
        saveOperation.recordsToSave = [space.underlyingRecord, share]

        let configuration = CKOperation.Configuration()
        configuration.qualityOfService = .utility

        saveOperation.configuration = configuration

        cloudkitContainer.currentDatabase.add(saveOperation)

        return saveOperation.publishers()
            .completion
            .map { _ in share }
            .eraseToAnyPublisher()
    }

    func delete(space: Space) -> AnyPublisher<Never, Swift.Error> {
        let deleteOperation = CKModifyRecordsOperation()
        deleteOperation.recordIDsToDelete = [space.underlyingRecord.recordID]

        let configuration = CKOperation.Configuration()
        configuration.qualityOfService = .utility

        deleteOperation.configuration = configuration

        cloudkitContainer.currentDatabase.add(deleteOperation)

        return deleteOperation.publishers()
            .completion
            .ignoreOutput()
            .eraseToAnyPublisher()
    }
}
