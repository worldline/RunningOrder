//
//  Cloudkit+Sprint.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 20/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import CloudKit

extension Sprint: CKRecordable {
    init(from record: CKRecord) throws {
        guard let name = record["name"] as? String else {
            throw CloudKitManager.Error.castFailure
        }

        guard let number = record["number"] as? Int else {
            throw CloudKitManager.Error.castFailure
        }

        guard let colorIdentifier = record["colorIdentifier"] as? String else {
            throw CloudKitManager.Error.castFailure
        }

        self.name = name
        self.number = number
        self.colorIdentifier = colorIdentifier
    }

    func encode(zoneId: CKRecordZone.ID) -> CKRecord {
        let sprintRecord = CKRecord(recordType: RecordType.sprint.rawValue, recordID: recordId(zoneId: zoneId))

        sprintRecord["name"] = self.name as CKRecordValue
        sprintRecord["number"] = self.number as CKRecordValue
        sprintRecord["colorIdentifier"] = self.colorIdentifier as CKRecordValue

        return sprintRecord
    }

    func recordId(zoneId: CKRecordZone.ID) -> CKRecord.ID {
        return CKRecord.ID(recordName: self.id, zoneID: zoneId)
    }
}
