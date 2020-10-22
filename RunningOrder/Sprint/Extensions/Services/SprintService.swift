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

    func delete(sprint: Sprint) -> AnyPublisher<Never, Swift.Error> {
        let record = sprint.encode(zoneId: cloudkitContainer.sharedZoneId)
        let deleteOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [record.recordID])

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
