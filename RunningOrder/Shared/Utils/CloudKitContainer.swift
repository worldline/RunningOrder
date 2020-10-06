//
//  CloudkitContainer.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 26/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import CloudKit
import Combine

extension CloudKitContainer {
    enum Mode {
        case owner
        case shared(ownerName: String)

        var isOwner: Bool {
            switch self {
            case .shared:
                return false
            case .owner:
                return true
            }
        }
    }
}

class CloudKitContainer {
    private static let createdCustomZoneKey = "CloudKitCreatedSharedZone"
    private static var createdCustomZone: Bool {
        get { return UserDefaults.standard.bool(forKey: createdCustomZoneKey) }
        set { UserDefaults.standard.set(newValue, forKey: createdCustomZoneKey) }
    }

    private static let sharedOwnerNameKey = "CloudKitSharedOwnerName"
    private static var sharedOwnerName: String? {
        get { return UserDefaults.standard.string(forKey: sharedOwnerNameKey) }
        set { UserDefaults.standard.set(newValue, forKey: sharedOwnerNameKey) }
    }

    private static let zoneName = "SharedZone"

    private let ownedZoneId = CKRecordZone.ID(zoneName: CloudKitContainer.zoneName, ownerName: CKCurrentUserDefaultName)

    private var cancellables = Set<AnyCancellable>()

    static let shared = CloudKitContainer() // singleton

    let container = CKContainer(identifier: "iCloud.com.worldline.RunningOrder")

    var sharedZoneId: CKRecordZone.ID {
        switch mode {
        case .owner:
            return ownedZoneId
        case .shared(let ownerName):
            return CKRecordZone.ID(zoneName: CloudKitContainer.zoneName, ownerName: ownerName)
        }
    }

    var currentDatabase: CKDatabase {
        switch mode {
        case .owner:
            return container.privateCloudDatabase
        case .shared:
            return container.sharedCloudDatabase
        }
    }

    var mode: Mode {
        didSet {
            switch mode {
            case .owner:
                Self.sharedOwnerName = nil
            case .shared(let ownerName):
                Self.sharedOwnerName = ownerName
            }

            if mode.isOwner != oldValue.isOwner {
                enableNotificationsIfNeeded()
            }
        }
    }

    // MARK: -

    init() {
        if let sharedOwnerName = CloudKitContainer.sharedOwnerName {
            mode = .shared(ownerName: sharedOwnerName)
        } else {
            mode = .owner
        }

        createCustomZoneIfNeeded()
        enableNotificationsIfNeeded()
    }

    private func createCustomZoneIfNeeded() {
        guard mode.isOwner && !CloudKitContainer.createdCustomZone else { return }

        Logger.verbose.log("shared zone creation")
        let sharedZone = CKRecordZone(zoneID: ownedZoneId)
        let zoneOperation = CKModifyRecordZonesOperation()
        zoneOperation.recordZonesToSave = [sharedZone]

        zoneOperation.modifyRecordZonesCompletionBlock = { _, _, error in
            if let error = error {
                Logger.error.log("error while creating custom zone : \(error)")
            } else {
                CloudKitContainer.createdCustomZone = true
            }
        }
        container.privateCloudDatabase.add(zoneOperation)
    }

    private func subscriptionId(for database: CKDatabase) -> CKSubscription.ID {
        switch database.databaseScope {
        case .private:
            return "privateDBSubscription"
        case .public:
            return "publicDBSubscription"
        case .shared:
            return "sharedDBSubscription"
        @unknown default:
            fatalError("unknown case \(database.databaseScope)")
        }
    }

    private func createSubscriptions(for database: CKDatabase) -> AnyPublisher<Never, Error> {
        let subscription = CKDatabaseSubscription(subscriptionID: subscriptionId(for: database))
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo

        let operation = CKModifySubscriptionsOperation(
            subscriptionsToSave: [subscription],
            subscriptionIDsToDelete: []
        )

        operation.qualityOfService = .utility

        database.add(operation)

        return operation.publisher()
            .ignoreOutput()
            .eraseToAnyPublisher()
    }

    // MARK: -

    func resetModeIfNeeded() {
        if !self.mode.isOwner {
            self.mode = .owner
        }
    }

    func enableNotificationsIfNeeded() {
        let database = currentDatabase

        return database.fetchAllSubscriptions()
            .filter { $0.isEmpty }
            .flatMap { _ in return self.createSubscriptions(for: database) }
            .sink(receiveFailure: { error in Logger.error.log(error) })
            .store(in: &cancellables)
    }

    func validateNotification(_ userInfo: [String: Any]) -> Bool {
        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo) else { return false }

        return notification.subscriptionID == subscriptionId(for: currentDatabase)
    }
}

enum RecordType: String {
    case sprint = "Sprint"
    case story = "Story"
    case storyInformation = "StoryInformation"
    case space = "Space"
}
