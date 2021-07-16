//
//  Cloudkit+Extensions.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 20/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import Combine
import CloudKit

extension CKQueryOperation {
    /// Combine publisher of an CKQueryOperation recordFetchedBlock completion block
    /// Each iteration in the completion block will result in a value sent by the publisher
    func publishers() -> (recordFetched: AnyPublisher<CKRecord, Error>, completion: AnyPublisher<CKQueryOperation.Cursor?, Error>) {
        let operationPublisher = PassthroughSubject<CKRecord, Error>()

        self.recordFetchedBlock = { record in
            operationPublisher.send(record)
        }

        let completionPublisher = PassthroughSubject<CKQueryOperation.Cursor?, Error>()

        self.queryCompletionBlock = { (cursor, error) in
            if let error = error {
                operationPublisher.send(completion: .failure(error))
                completionPublisher.send(completion: .failure(error))
            } else {
                operationPublisher.send(completion: .finished)
                completionPublisher.send(cursor)
                completionPublisher.send(completion: .finished)
            }
        }
        return (operationPublisher.eraseToAnyPublisher(), completionPublisher.eraseToAnyPublisher())
    }
}

extension CKModifyRecordsOperation {
    /// Wrapper for block based events sent inside Modify Records Operations.
    func publishers() -> (perRecordProgress: AnyPublisher<(CKRecord, Double), Error>, perRecord: AnyPublisher<CKRecord, Error>, completion: AnyPublisher<([CKRecord]?, [CKRecord.ID]?), Error>) {
        let perRecord = PassthroughSubject<CKRecord, Error>()
        self.perRecordCompletionBlock = { (record, error) in
            if let error = error {
                perRecord.send(completion: .failure(error))
            } else {
                perRecord.send(record)
            }
        }

        let perRecordProgress = PassthroughSubject<(CKRecord, Double), Error>()
        self.perRecordProgressBlock = { record, progress in
            perRecordProgress.send((record, progress))
        }

        let completion = PassthroughSubject<([CKRecord]?, [CKRecord.ID]?), Error>()
        self.modifyRecordsCompletionBlock = { records, deletedIds, error in
            Logger.debug.log("publisher - modify - completionBlock ok")
            completion.send((records, deletedIds))
            if let error = error {
                perRecord.send(completion: .failure(error))
                perRecordProgress.send(completion: .failure(error))
                completion.send(completion: .failure(error))
            } else {
                perRecord.send(completion: .finished)
                perRecordProgress.send(completion: .finished)
                completion.send(completion: .finished)
            }
        }

        return (perRecordProgress.eraseToAnyPublisher(), perRecord.eraseToAnyPublisher(), completion.eraseToAnyPublisher())
    }
}

extension CKAcceptSharesOperation {
    func publishers() -> (perShare: AnyPublisher<(CKShare.Metadata, CKShare?), Error>, acceptShares: AnyPublisher<Never, Error>) {
        let perShare = PassthroughSubject<(CKShare.Metadata, CKShare?), Error>()
        self.perShareCompletionBlock = { metadata, share, error in
            if let error = error {
                perShare.send(completion: .failure(error))
            } else {
                perShare.send((metadata, share))
            }
        }

        let acceptShares = PassthroughSubject<Never, Error>()
        self.acceptSharesCompletionBlock = { error in
            if let error = error {
                perShare.send(completion: .failure(error))
                acceptShares.send(completion: .failure(error))
            } else {
                perShare.send(completion: .finished)
                acceptShares.send(completion: .finished)
            }
        }

        return (perShare.eraseToAnyPublisher(), acceptShares.eraseToAnyPublisher())
    }
}

extension CKFetchRecordsOperation {
    func publishers() -> (perRecordProgress: AnyPublisher<(CKRecord.ID, Double), Error>, perRecord: AnyPublisher<(CKRecord?, CKRecord.ID?), Error>, completion: AnyPublisher<[CKRecord.ID: CKRecord]?, Error>) {
        let perRecord = PassthroughSubject<(CKRecord?, CKRecord.ID?), Error>()
        self.perRecordCompletionBlock = { (record, id, error) in
            if let error = error {
                perRecord.send(completion: .failure(error))
            } else {
                perRecord.send((record, id))
            }
        }

        let perRecordProgress = PassthroughSubject<(CKRecord.ID, Double), Error>()
        self.perRecordProgressBlock = { record, double in
            perRecordProgress.send((record, double))
        }

        let completion = PassthroughSubject<[CKRecord.ID: CKRecord]?, Error>()
        self.fetchRecordsCompletionBlock = { records, error in
            completion.send(records)
            if let error = error {
                perRecord.send(completion: .failure(error))
                perRecordProgress.send(completion: .failure(error))
                completion.send(completion: .failure(error))
            } else {
                perRecord.send(completion: .finished)
                perRecordProgress.send(completion: .finished)
                completion.send(completion: .finished)
            }
        }

        return (perRecordProgress.eraseToAnyPublisher(), perRecord.eraseToAnyPublisher(), completion.eraseToAnyPublisher())
    }
}

extension CKModifySubscriptionsOperation {
    func publisher() -> AnyPublisher<([CKSubscription]?, [CKSubscription.ID]?), Error> {
        let modifySubscriptions = PassthroughSubject<([CKSubscription]?, [CKSubscription.ID]?), Error>()
        self.modifySubscriptionsCompletionBlock = { subscriptions, ids, error in
            if let error = error {
                modifySubscriptions.send(completion: .failure(error))
                return
            }

            modifySubscriptions.send((subscriptions, ids))
            modifySubscriptions.send(completion: .finished)
        }

        return modifySubscriptions.eraseToAnyPublisher()
    }
}

extension CKFetchRecordZoneChangesOperation {
    func publishers() -> (fetchRecordZoneChangesCompletion: AnyPublisher<Never, Error>,
                          recordChanged: AnyPublisher<CKRecord, Never>,
                          recordWithIDWasDeleted: AnyPublisher<(recordId: CKRecord.ID, recordType: CKRecord.RecordType), Never>,
                          recordZoneChangeTokensUpdated: AnyPublisher<(zoneId: CKRecordZone.ID, serverToken: CKServerChangeToken?, clientToken: Data?), Never>,
                          recordZoneFetchCompletion: AnyPublisher<(zoneId: CKRecordZone.ID, serverToken: CKServerChangeToken?, clientToken: Data?, isMoreComing: Bool), Error>) {
        let recordWithIDWasDeleted = PassthroughSubject<(recordId: CKRecord.ID, recordType: CKRecord.RecordType), Never>()
        self.recordWithIDWasDeletedBlock = { id, type in
            recordWithIDWasDeleted.send((id, type))
        }

        let recordChanged = PassthroughSubject<CKRecord, Never>()
        self.recordChangedBlock = { record in
            recordChanged.send(record)
        }

        let recordZoneChangeTokensUpdated = PassthroughSubject<(zoneId: CKRecordZone.ID, serverToken: CKServerChangeToken?, clientToken: Data?), Never>()
        self.recordZoneChangeTokensUpdatedBlock = { id, serverToken, clientToken in
            recordZoneChangeTokensUpdated.send((id, serverToken, clientToken))
        }

        let recordZoneFetchCompletion = PassthroughSubject<(zoneId: CKRecordZone.ID, serverToken: CKServerChangeToken?, clientToken: Data?, isMoreComing: Bool), Error>()
        self.recordZoneFetchCompletionBlock = { id, serverToken, clientToken, moreComing, error in
            if let error = error {
                recordZoneFetchCompletion.send(completion: .failure(error))
            } else {
                recordZoneFetchCompletion.send((id, serverToken, clientToken, moreComing))
            }
        }

        let fetchRecordZoneChangesCompletion = PassthroughSubject<Never, Error>()
        self.fetchRecordZoneChangesCompletionBlock = { error in
            recordChanged.send(completion: .finished)
            recordZoneChangeTokensUpdated.send(completion: .finished)
            recordWithIDWasDeleted.send(completion: .finished)
            recordZoneFetchCompletion.send(completion: .finished)

            if let error = error {
                fetchRecordZoneChangesCompletion.send(completion: .failure(error))
            } else {
                fetchRecordZoneChangesCompletion.send(completion: .finished)
            }
        }

        return (
            fetchRecordZoneChangesCompletion: fetchRecordZoneChangesCompletion.eraseToAnyPublisher(),
            recordChanged: recordChanged.eraseToAnyPublisher(),
            recordWithIDWasDeleted: recordWithIDWasDeleted.eraseToAnyPublisher(),
            recordZoneChangeTokensUpdated: recordZoneChangeTokensUpdated.eraseToAnyPublisher(),
            recordZoneFetchCompletion: recordZoneFetchCompletion.eraseToAnyPublisher()
        )
    }
}

extension CKFetchDatabaseChangesOperation {
    func publishers() -> (fetchDatabaseChangesCompletion: AnyPublisher<(token: CKServerChangeToken?, moreComing: Bool), Error>, changeTokenUpdated: AnyPublisher<CKServerChangeToken, Never>, recordZoneWithIDChanged: AnyPublisher<CKRecordZone.ID, Never>, recordZoneWithIDWasDeleted: AnyPublisher<CKRecordZone.ID, Never>, recordZoneWithIDWasPurged: AnyPublisher<CKRecordZone.ID, Never>) {

        let changeTokenUpdated = PassthroughSubject<CKServerChangeToken, Never>()
        self.changeTokenUpdatedBlock = { token in
            changeTokenUpdated.send(token)
        }

        let recordZoneWithIDChanged = PassthroughSubject<CKRecordZone.ID, Never>()
        self.recordZoneWithIDChangedBlock = { id in
            recordZoneWithIDChanged.send(id)
        }

        let recordZoneWithIDWasDeleted = PassthroughSubject<CKRecordZone.ID, Never>()
        self.recordZoneWithIDWasDeletedBlock = { id in
            recordZoneWithIDWasDeleted.send(id)
        }

        let recordZoneWithIDWasPurged = PassthroughSubject<CKRecordZone.ID, Never>()
        self.recordZoneWithIDWasPurgedBlock = { id in
            recordZoneWithIDWasPurged.send(id)
        }

        let fetchDatabaseChangesCompletion = PassthroughSubject<(token: CKServerChangeToken?, moreComing: Bool), Error>()
        self.fetchDatabaseChangesCompletionBlock = { token, bool, error in
            changeTokenUpdated.send(completion: .finished)
            recordZoneWithIDChanged.send(completion: .finished)
            recordZoneWithIDWasDeleted.send(completion: .finished)
            recordZoneWithIDWasPurged.send(completion: .finished)

            if let error = error {
                fetchDatabaseChangesCompletion.send(completion: .failure(error))
            } else {
                fetchDatabaseChangesCompletion.send((token, bool))
                fetchDatabaseChangesCompletion.send(completion: .finished)
            }
        }

        return (
            fetchDatabaseChangesCompletion: fetchDatabaseChangesCompletion.eraseToAnyPublisher(),
            changeTokenUpdated: changeTokenUpdated.eraseToAnyPublisher(),
            recordZoneWithIDChanged: recordZoneWithIDChanged.eraseToAnyPublisher(),
            recordZoneWithIDWasDeleted: recordZoneWithIDWasDeleted.eraseToAnyPublisher(),
            recordZoneWithIDWasPurged: recordZoneWithIDWasPurged.eraseToAnyPublisher()
        )
    }
}

extension CKFetchRecordZonesOperation {
    func publisher() -> AnyPublisher<[CKRecordZone.ID: CKRecordZone], Error> {
        let fetchRecordZonesCompletion = PassthroughSubject<[CKRecordZone.ID: CKRecordZone], Error>()
        self.fetchRecordZonesCompletionBlock = { result, error in
            if let error = error {
                fetchRecordZonesCompletion.send(completion: .failure(error))
                return
            }

            guard let result = result else {
                fetchRecordZonesCompletion.send(completion: .failure(BasicError.noValue))
                return
            }
            fetchRecordZonesCompletion.send(result)
            fetchRecordZonesCompletion.send(completion: .finished)
        }

        return fetchRecordZonesCompletion.eraseToAnyPublisher()
    }
}

extension CKContainer {
    func status(forApplicationPermission applicationPermission: CKContainer_Application_Permissions) -> AnyPublisher<CKContainer_Application_PermissionStatus, Error> {
        Future { promise in
            self.status(forApplicationPermission: applicationPermission) { status, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(status))
                }
            }
        }.eraseToAnyPublisher()
    }

    func requestApplicationPermission(applicationPermission: CKContainer_Application_Permissions) -> AnyPublisher<CKContainer_Application_PermissionStatus, Error> {
        Future { promise in
            self.requestApplicationPermission(applicationPermission, completionHandler: { status, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(status))
                }
            })
        }.eraseToAnyPublisher()
    }

    func discoverUserIdentity(withUserRecordID recordID: CKRecord.ID) -> AnyPublisher<CKUserIdentity, Error> {
        Future { promise in
            self.discoverUserIdentity(withUserRecordID: recordID, completionHandler: { identity, error in
                switch (error, identity) {
                case (.some(let error), _):
                    promise(.failure(error))
                case (nil, nil):
                    promise(.failure(BasicError.noValue))
                case (nil, .some(let identity)):
                    promise(.success(identity))
                }
            })
        }.eraseToAnyPublisher()
    }
}

// MARK: -

extension CKRecord {
    /// A function equivalent to the CKRecord subscript to access to a record property
    /// - Parameter key: The string key of the property
    /// - Throws: If the property is not contained in the CKRecord
    /// - Returns: The property value which conforms to the CKRecordValueProtocol
    func property<T: CKRecordValueProtocol>(_ key: String) throws -> T {
        guard let value = self[key] as? T else {
            throw CKRecord.Error.decodeFailure(for: key, typeDescription: String(describing: T.self))
        }
        return value
    }

    enum Error: LocalizedError {
        case decodeFailure(for: String, typeDescription: String)

        var failureReason: String? {
            switch self {
            case .decodeFailure(let key, let type):
                return "Couldn't decode property at key : \(key) as type : \(type)"
            }
        }
    }
}

extension CKDatabase {
    enum Error: LocalizedError {
        case missingSubscriptions(database: CKDatabase)

        var failureReason: String? {
            switch self {
            case .missingSubscriptions(let database):
                return "No Subscription found in \(database)"
            }
        }
    }

    func fetchAllSubscriptions() -> AnyPublisher<[CKSubscription], Swift.Error> {
        let publisher = PassthroughSubject<[CKSubscription], Swift.Error>()

        self.fetchAllSubscriptions { subscriptions, error in
            if let error = error {
                publisher.send(completion: .failure(error))
                return
            }

            guard let subscriptions = subscriptions else {
                publisher.send(completion: .failure(Error.missingSubscriptions(database: self)))
                return
            }

            publisher.send(subscriptions)
            publisher.send(completion: .finished)
        }

        return publisher.eraseToAnyPublisher()
    }
}
