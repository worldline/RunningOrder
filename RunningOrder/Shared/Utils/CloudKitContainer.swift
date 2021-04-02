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
import struct SwiftUI.AppStorage

fileprivate extension CKDatabase {
    var subscriptionId: CKSubscription.ID {
        switch self.databaseScope {
        case .private:
            return "privateDBSubscription"
        case .public:
            return "publicDBSubscription"
        case .shared:
            return "sharedDBSubscription"
        @unknown default:
            fatalError("unknown case \(self.databaseScope)")
        }
    }
}

final class CloudKitContainer {
    @AppStorage("CloudKitCreatedSharedZone") private static var createdCustomZone: Bool = false

    private static let zoneName = "SharedZone"

    let ownedZoneId = CKRecordZone.ID(
        zoneName: CloudKitContainer.zoneName,
        ownerName: CKCurrentUserDefaultName
    )

    let cloudContainer = CKContainer(identifier: "iCloud.com.worldline.RunningOrder")

    private var cancellables = Set<AnyCancellable>()

    private static func createSubscriptions(for database: CKDatabase) -> AnyPublisher<Never, Error> {
        let subscription = CKDatabaseSubscription(subscriptionID: database.subscriptionId)
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

    private static func askPermissionForDiscoverabilityIfNeeded(in container: CKContainer) -> AnyCancellable {
        container.status(forApplicationPermission: .userDiscoverability)
            .filter { $0 == .initialState }
            .flatMap { _ in container.requestApplicationPermission(applicationPermission: .userDiscoverability) }
            .sink(receiveFailure: { error in
                Logger.error.log("error at requesting permission : \(error)")
            }, receiveValue: { status in
                switch status {
                case .couldNotComplete:
                    Logger.error.log("error when requesting permission for discoverability")
                case .granted:
                    Logger.debug.log("Discoverability granted")
                case .denied:
                    Logger.debug.log("Discoverability denied :'(")
                case .initialState:
                    fallthrough
                @unknown default:
                    break
                }
            })
    }

    private func createCustomZoneIfNeeded() {
        guard !CloudKitContainer.createdCustomZone else { return }

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
        cloudContainer.privateCloudDatabase.add(zoneOperation)
    }

    func database(for zoneId: CKRecordZone.ID) -> CKDatabase {
        let scope: CKDatabase.Scope = zoneId.ownerName == CKCurrentUserDefaultName ? .private : .shared
        return cloudContainer.database(with: scope)
    }

    func enableNotificationsIfNeeded(for zoneId: CKRecordZone.ID) {
        let databaseToEnable = database(for: zoneId)
        databaseToEnable.fetchAllSubscriptions()
            .filter { $0.isEmpty }
            .flatMap { _ in Self.createSubscriptions(for: databaseToEnable) }
            .sink(receiveFailure: { error in Logger.error.log(error) })
            .store(in: &cancellables)
    }

    static var shared: CloudKitContainer = .init()

    private init() {
        createCustomZoneIfNeeded()

        Self.askPermissionForDiscoverabilityIfNeeded(in: cloudContainer)
            .store(in: &cancellables)
    }

    // resultats possible : pas validé, valide database privé, valide database shared
    func validateNotification(_ userInfo: [String: Any]) -> Bool {
        guard CKNotification(fromRemoteNotificationDictionary: userInfo) != nil else { return false }

//        if self.cloudContainer.privateCloudDatabase.subscriptionId == notification.subscriptionID {
//
//        }
        return true
    }

    @Stored(fileName: "owners", directory: FileManager.SearchPathDirectory.applicationSupportDirectory) private var ownerData: Data?

    private var ownerNames: Set<String> {
        get {
            guard let data = ownerData else { return .init() }

            do {
                return try JSONDecoder().decode(Set<String>.self, from: data)
            } catch {
                Logger.error.log(error)
                return .init()
            }
        }

        set {
            do {
                ownerData = try JSONEncoder().encode(newValue)
            } catch {
                Logger.error.log(error)
            }
        }
    }

    var owners: [CKRecordZone.ID] {
        ownerNames.map {
            CKRecordZone.ID(zoneName: Self.zoneName, ownerName: $0)
        }
    }

    func saveOwnerName(_ ownerName: String) {
        ownerNames.insert(ownerName)
    }
}

enum RecordType: String {
    case sprint = "Sprint"
    case story = "Story"
    case storyInformation = "StoryInformation"
    case space = "Space"
}
