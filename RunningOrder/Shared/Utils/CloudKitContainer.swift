//
//  CloudkitContainer.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 26/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import CloudKit

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

    let container = CKContainer(identifier: "iCloud.com.worldline.RunningOrder")

    var sharedZoneId: CKRecordZone.ID {
        switch mode {
        case .owner:
            return ownedZoneId
        case .shared(let ownerName):
            return CKRecordZone.ID(zoneName: CloudKitContainer.zoneName, ownerName: ownerName)
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
        }
    }

    init() {
        if let sharedOwnerName = CloudKitContainer.sharedOwnerName {
            mode = .shared(ownerName: sharedOwnerName)
        } else {
            mode = .owner
        }

        createCustomZoneIfNeeded()
    }

    static let shared = CloudKitContainer() // singleton

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

    func resetModeIfNeeded() {
        if !self.mode.isOwner {
            self.mode = .owner
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
}

enum RecordType: String {
    case sprint = "Sprint"
    case story = "Story"
    case storyInformation = "StoryInformation"
    case space = "Space"
}
