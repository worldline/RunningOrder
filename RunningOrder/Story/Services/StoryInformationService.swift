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
