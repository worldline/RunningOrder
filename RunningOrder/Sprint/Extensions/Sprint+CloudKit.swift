//
//  Sprint+CloudKit.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 20/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import CloudKit

extension Sprint: CKRecordable {
    init(from record: CKRecord) throws {
        let ref: CKRecord.Reference = try record.property("spaceId")
        self.spaceId = ref.recordID.recordName
        self.name = try record.property("name")
        self.number = try record.property("number")
        self.colorIdentifier = try record.property("colorIdentifier")
        self.zoneId = record.recordID.zoneID
        self.closed = (try? record.property("closed")) ?? false
    }

    func encode() -> CKRecord {
        let sprintRecord = CKRecord(recordType: RecordType.sprint.rawValue, recordID: recordId(zoneId: zoneId))

        sprintRecord["spaceId"] = CKRecord.Reference(recordID: spaceRecordId(zoneId: zoneId), action: .deleteSelf)
        sprintRecord.parent = CKRecord.Reference(recordID: spaceRecordId(zoneId: zoneId), action: .none)

        sprintRecord["name"] = self.name
        sprintRecord["number"] = self.number
        sprintRecord["colorIdentifier"] = self.colorIdentifier
        sprintRecord["closed"] = self.closed

        return sprintRecord
    }

    private func recordId(zoneId: CKRecordZone.ID) -> CKRecord.ID {
        return CKRecord.ID(recordName: self.id, zoneID: zoneId)
    }

    private func spaceRecordId(zoneId: CKRecordZone.ID) -> CKRecord.ID {
        return CKRecord.ID(recordName: self.spaceId, zoneID: zoneId)
    }
}
