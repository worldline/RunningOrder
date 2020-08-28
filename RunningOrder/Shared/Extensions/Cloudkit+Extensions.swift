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
    func recordFetchedPublisher() -> AnyPublisher<CKRecord, Error> {
        let operationPublisher = PassthroughSubject<CKRecord, Error>()

        self.recordFetchedBlock = { record in
            operationPublisher.send(record)
        }

        self.queryCompletionBlock = { (_, error) in
            if let error = error {
                operationPublisher.send(completion: .failure(error))
            }

            operationPublisher.send(completion: .finished)
        }
        return operationPublisher.eraseToAnyPublisher()
    }
}

extension CKModifyRecordsOperation {
    /// Combine publisher of an CKModifyRecordsOperation perRecordCompletionBlock completion block
    /// Each iteration in the completion block will result in a value sent by the publisher
    func perRecordPublisher() -> AnyPublisher<CKRecord, Error> {
        let operationPublisher = PassthroughSubject<CKRecord, Error>()

        self.perRecordCompletionBlock = { (record, error) in
            if let error = error {
                operationPublisher.send(completion: .failure(error))
            } else {
                operationPublisher.send(record)
            }
        }

        self.completionBlock = {
            operationPublisher.send(completion: .finished)
        }

        return operationPublisher.eraseToAnyPublisher()
    }
}

extension CKRecord {
    /// A function equivalent to the CKRecord subscript to access to a record property
    /// - Parameter key: The string key of the property
    /// - Throws: If the property is not contained in the CKRecord
    /// - Returns: The property value which conforms to the CKRecordValueProtocol
    func property<T: CKRecordValueProtocol>(_ key: String) throws -> T {
        guard let value = self[key] as? T else {
            throw CKRecord.Error.decodeFailure(for: key)
        }
        return value
    }

    enum Error: Swift.Error {
        case decodeFailure(for: String)
    }
}
