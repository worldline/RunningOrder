//
//  Cloudkit+Story.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 20/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import CloudKit

extension Story: CKRecordable {

    init(from record: CKRecord) throws {
        self.name = try record.property("name")
        self.ticketReference = try record.property("ticketReference")
        self.epic = try record.property("epic")

        let sprintReference: CKRecord.Reference = try record.property("sprintId")
        self.sprintId = sprintReference.recordID.recordName
    }

    func encode(zoneId: CKRecordZone.ID) -> CKRecord {
        let storyRecord = CKRecord(recordType: RecordType.story.rawValue, recordID: recordId(zoneId: zoneId))

        storyRecord["name"] = self.name as CKRecordValue
        storyRecord["ticketReference"] = self.ticketReference as CKRecordValue
        storyRecord["epic"] = self.epic as CKRecordValue
        storyRecord["sprintId"] = CKRecord.Reference(recordID: sprintRecordId(zoneId: zoneId), action: .deleteSelf) as CKRecordValue

        return storyRecord
    }

    private func recordId(zoneId: CKRecordZone.ID) -> CKRecord.ID {
        return CKRecord.ID(recordName: self.id, zoneID: zoneId)
    }

    private func sprintRecordId(zoneId: CKRecordZone.ID) -> CKRecord.ID {
        return CKRecord.ID(recordName: self.sprintId, zoneID: zoneId)
    }
}
