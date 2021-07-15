//
//  VideoService.swift
//  RunningOrder
//
//  Created by Clément Nonn on 13/07/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation
import Combine
import CloudKit

/// The service responsible of all the Video CRUD operation
class VideoService {
    let cloudkitContainer = CloudKitContainer.shared

    func save(video: Video) -> AnyPublisher<Video, Swift.Error> {
        let videoRecord = video.encode()

        let saveOperation = CKModifyRecordsOperation(recordsToSave: [videoRecord], recordIDsToDelete: nil)

        let configuration = CKOperation.Configuration()
        configuration.qualityOfService = .utility

        saveOperation.configuration = configuration
        saveOperation.savePolicy = .allKeys // save policy to handle update

        cloudkitContainer.database(for: video.zoneId).add(saveOperation)

        return saveOperation.publishers().perRecord
            .tryMap { try Video.init(from: $0) }
            .eraseToAnyPublisher()
    }

    func delete(video: Video) -> AnyPublisher<Never, Swift.Error> {
        let record = video.encode()
        let deleteOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [record.recordID])

        let configuration = CKOperation.Configuration()
        configuration.qualityOfService = .utility

        deleteOperation.configuration = configuration

        cloudkitContainer.database(for: video.zoneId).add(deleteOperation)

        return deleteOperation.publishers()
            .completion
            .ignoreOutput()
            .eraseToAnyPublisher()
    }
}
