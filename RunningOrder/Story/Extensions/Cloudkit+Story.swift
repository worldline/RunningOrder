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
        guard let name = record["name"] as? String else {
            throw CloudKitManager.Error.castFailure
        }

        guard let ticketReference = record["ticketReference"] as? String else {
            throw CloudKitManager.Error.castFailure
        }

        guard let epic = record["epic"] as? String else {
            throw CloudKitManager.Error.castFailure
        }

        guard let sprintReference = record["sprintId"] as? CKRecord.Reference else {
            throw CloudKitManager.Error.castFailure
        }

        self.name = name
        self.ticketReference = ticketReference
        self.epic = epic
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

    func recordId(zoneId: CKRecordZone.ID) -> CKRecord.ID {
        return CKRecord.ID(recordName: self.id, zoneID: zoneId)
    }

    func sprintRecordId(zoneId: CKRecordZone.ID) -> CKRecord.ID {
        return CKRecord.ID(recordName: self.sprintId, zoneID: zoneId)
    }
}
