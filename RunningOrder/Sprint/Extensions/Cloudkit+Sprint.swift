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
        self.name = try record.property("name")
        self.number = try record.property("number")
        self.colorIdentifier = try record.property("colorIdentifier")
    }

    func encode(zoneId: CKRecordZone.ID) -> CKRecord {
        let sprintRecord = CKRecord(recordType: RecordType.sprint.rawValue, recordID: recordId(zoneId: zoneId))

        sprintRecord["name"] = self.name as CKRecordValue
        sprintRecord["number"] = self.number as CKRecordValue
        sprintRecord["colorIdentifier"] = self.colorIdentifier as CKRecordValue

        return sprintRecord
    }

    private func recordId(zoneId: CKRecordZone.ID) -> CKRecord.ID {
        return CKRecord.ID(recordName: self.id, zoneID: zoneId)
    }
}
