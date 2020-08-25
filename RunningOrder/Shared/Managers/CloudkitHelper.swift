//
//  CloudkitManager.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 20/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import CloudKit
import Combine

class CloudKitManager {

    enum Error: Swift.Error {
        case recordFailure
        case castFailure
        case deleteFailure
    }

    var createdCustomZone: Bool {
        get { return UserDefaults.standard.bool(forKey: "CloudKitCreatedSharedZone") }
        set { UserDefaults.standard.set(newValue, forKey: "CloudKitCreatedSharedZone") }
    }

    let sharedZoneId = CKRecordZone.ID(zoneName: "SharedZone", ownerName: CKCurrentUserDefaultName)

    let container = CKContainer(identifier: "iCloud.com.worldline.RunningOrder")

    func createCustomZone() {
        if !createdCustomZone {
            print("shared zone creation")
            let sharedZone = CKRecordZone(zoneID: sharedZoneId)
            let zoneOperation = CKModifyRecordZonesOperation()
            zoneOperation.recordZonesToSave = [sharedZone]

            zoneOperation.modifyRecordZonesCompletionBlock = { _, _, error in
                if let error = error {
                    print("error while creating custom zone : \(error)")
                } else {
                    self.createdCustomZone = true
                }
            }

            container.privateCloudDatabase.add(zoneOperation)
        }
    }

    func fetchAllSprints() -> AnyPublisher<[Sprint], Swift.Error> {

        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: RecordType.sprint.rawValue, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]


        let fetchOperation = CKQueryOperation(query: query)

        fetchOperation.zoneID = sharedZoneId

        let configuration = CKOperation.Configuration()
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5

        fetchOperation.configuration = configuration

        container.privateCloudDatabase.add(fetchOperation)

        return fetchOperation
            .recordFetchedPublisher()
            .tryMap { try Sprint.init(from: $0) }
            .collect()
            .eraseToAnyPublisher()
    }

    func fetchStories(from sprintId: Sprint.ID) -> AnyPublisher<[Story], Swift.Error> {
        let reference = CKRecord.Reference(recordID: CKRecord.ID(recordName: sprintId, zoneID: sharedZoneId), action: .deleteSelf)
        let predicate = NSPredicate(format: "sprintId == %@", reference)
        let query = CKQuery(recordType: RecordType.story.rawValue, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        let fetchOperation = CKQueryOperation(query: query)

        fetchOperation.zoneID = sharedZoneId

        let configuration = CKOperation.Configuration()
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5

        fetchOperation.configuration = configuration

        container.privateCloudDatabase.add(fetchOperation)

        return fetchOperation
            .recordFetchedPublisher()
            .tryMap { try Story.init(from: $0) }
            .collect()
            .eraseToAnyPublisher()
    }

    func fetchStoryInformation(from storyId: Story.ID) -> AnyPublisher<StoryInformation, Swift.Error> {
        let reference = CKRecord.Reference(recordID: CKRecord.ID(recordName: storyId, zoneID: sharedZoneId), action: .deleteSelf)
        let predicate = NSPredicate(format: "storyId == %@", reference)
        let query = CKQuery(recordType: RecordType.storyInformation.rawValue, predicate: predicate)

        let fetchOperation = CKQueryOperation(query: query)

        fetchOperation.zoneID = sharedZoneId

        let configuration = CKOperation.Configuration()
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5

        fetchOperation.configuration = configuration

        container.privateCloudDatabase.add(fetchOperation)

        return fetchOperation
            .recordFetchedPublisher()
            .tryMap { try StoryInformation.init(from: $0) }
            .eraseToAnyPublisher()
    }

    func save(sprint: Sprint) -> AnyPublisher<Sprint, Swift.Error> {
        let sprintRecord = sprint.encode(zoneId: sharedZoneId)

        let saveOperation = CKModifyRecordsOperation()
        saveOperation.recordsToSave = [sprintRecord]

        let configuration = CKOperation.Configuration()
        configuration.qualityOfService = .utility

        saveOperation.configuration = configuration

        container.privateCloudDatabase.add(saveOperation)

        return saveOperation.perRecordPublisher()
            .tryMap { try Sprint.init(from: $0) }
            .eraseToAnyPublisher()
    }

    func save(story: Story) -> AnyPublisher<Story, Swift.Error> {
        let storyRecord = story.encode(zoneId: sharedZoneId)

        let saveOperation = CKModifyRecordsOperation()
        saveOperation.recordsToSave = [storyRecord]

        let configuration = CKOperation.Configuration()
        configuration.qualityOfService = .utility

        saveOperation.configuration = configuration

        container.privateCloudDatabase.add(saveOperation)

        return saveOperation.perRecordPublisher()
            .tryMap { try Story.init(from: $0) }
            .eraseToAnyPublisher()
    }

    func save(storyInformations: [StoryInformation]) -> AnyPublisher<[StoryInformation], Swift.Error> {
        let storyInformationRecords = storyInformations.map { $0.encode(zoneId: sharedZoneId) }

        let saveOperation = CKModifyRecordsOperation()
        saveOperation.recordsToSave = storyInformationRecords

        let configuration = CKOperation.Configuration()
        configuration.qualityOfService = .utility

        saveOperation.configuration = configuration
        saveOperation.savePolicy = .allKeys // save policy to handle update

        container.privateCloudDatabase.add(saveOperation)

        return saveOperation.perRecordPublisher()
            .tryMap { try StoryInformation.init(from: $0) }
            .collect()
            .eraseToAnyPublisher()
    }
}

enum RecordType: String {
    case sprint = "Sprint"
    case story = "Story"
    case storyInformation = "StoryInformation"
}
