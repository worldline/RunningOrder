//
//  CloudkitContainer.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 26/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitContainer {
    private var createdCustomZone: Bool {
        get { return UserDefaults.standard.bool(forKey: "CloudKitCreatedSharedZone") }
        set { UserDefaults.standard.set(newValue, forKey: "CloudKitCreatedSharedZone") }
    }

    let sharedZoneId = CKRecordZone.ID(zoneName: "SharedZone", ownerName: CKCurrentUserDefaultName)

    let container = CKContainer(identifier: "iCloud.com.worldline.RunningOrder")

    static let shared = CloudKitContainer() // singleton

    func createCustomZoneIfNeeded() {
        guard !createdCustomZone else { return }

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

enum RecordType: String {
    case sprint = "Sprint"
    case story = "Story"
    case storyInformation = "StoryInformation"
}
