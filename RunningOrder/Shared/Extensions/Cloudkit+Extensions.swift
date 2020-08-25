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
