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

extension SpaceService {
    enum Error: LocalizedError {
        case noShareFound

        var failureReason: String? {
            switch self {
            case .noShareFound:
                return "No share found in the provided `CKRecord`."
            }
        }
    }
}

/// The service responsible of all the Sprint CRUD operation
class SpaceService {
    let cloudkitContainer = CloudKitContainer.shared
    var cancellables = Set<AnyCancellable>()

    func fetchShared(_ id: CKRecord.ID) -> AnyPublisher<Space, Swift.Error> {
        let operation = CKFetchRecordsOperation(recordIDs: [id])
        cloudkitContainer.cloudContainer.sharedCloudDatabase.add(operation)

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

    func save(space: Space) -> AnyPublisher<Space, Swift.Error> {
        let saveOperation = CKModifyRecordsOperation()
        saveOperation.recordsToSave = [space.underlyingRecord]

        let configuration = CKOperation.Configuration()
        configuration.qualityOfService = .utility

        saveOperation.configuration = configuration

        cloudkitContainer.database(for: space.zoneId).add(saveOperation)

        return saveOperation.publishers().perRecord
            .tryMap { Space(underlyingRecord: $0) }
            .eraseToAnyPublisher()
    }

    func getShare(for space: Space) -> AnyPublisher<CKShare, Swift.Error> {
        guard let existingShareReference = space.underlyingRecord.share else {
            fatalError("this call shouldn't be done without verfying the share optionality")
        }

        let operation = CKFetchRecordsOperation(recordIDs: [existingShareReference.recordID])
        cloudkitContainer.database(for: space.zoneId).add(operation)
        return operation.publishers()
            .completion
            .compactMap { $0?[existingShareReference.recordID] as? CKShare }
            .eraseToAnyPublisher()
    }

    func saveAndShare(space: Space) -> AnyPublisher<CKShare, Swift.Error> {
        let share = CKShare(rootRecord: space.underlyingRecord)
        share[CKShare.SystemFieldKey.title] = space.name

        let saveOperation = CKModifyRecordsOperation()
        saveOperation.recordsToSave = [space.underlyingRecord, share]

        let configuration = CKOperation.Configuration()
        configuration.qualityOfService = .utility

        saveOperation.configuration = configuration

        cloudkitContainer.database(for: space.zoneId).add(saveOperation)

        return saveOperation.publishers()
            .completion
            .map { _ in share }
            .eraseToAnyPublisher()
    }

    func delete(space: Space) -> AnyPublisher<Never, Swift.Error> {
        let deleteOperation = CKModifyRecordsOperation()
        let recordIdToDelete: CKRecord.ID

        if space.underlyingRecord.recordID.zoneID.ownerName == CKCurrentUserDefaultName {
            recordIdToDelete = space.underlyingRecord.recordID
        } else {
            if let shareId = space.underlyingRecord.share?.recordID {
                recordIdToDelete = shareId
            } else {
                Logger.error.log("couldn't find the id of the share this way")
                return Fail(error: Error.noShareFound).eraseToAnyPublisher()
            }
        }
        deleteOperation.recordIDsToDelete = [recordIdToDelete]

        let configuration = CKOperation.Configuration()
        configuration.qualityOfService = .utility

        deleteOperation.configuration = configuration

        cloudkitContainer.database(for: space.zoneId).add(deleteOperation)

        return deleteOperation.publishers()
            .completion
            .ignoreOutput()
            .eraseToAnyPublisher()
    }

    func acceptShare(metadata: CKShare.Metadata) -> AnyPublisher<CKShare.Metadata, Swift.Error> {
        let acceptSharesOperation = CKAcceptSharesOperation(shareMetadatas: [metadata])

        let remoteContainer = CKContainer(identifier: metadata.containerIdentifier)

        remoteContainer.add(acceptSharesOperation)

        return acceptSharesOperation.publishers()
            .perShare
            .map { return $0.0 }
            .eraseToAnyPublisher()
    }
}
