//
//  Space.swift
//  RunningOrder
//
//  Created by Clément Nonn on 21/09/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import CloudKit

/// A work space, referenced from all sprints.
/// What we share between users is a space, with all data hierarchy beneath it.
struct Space {
    var id: ID { underlyingRecord.recordID.recordName }
    var name: String {
        do {
            return try underlyingRecord.property("name")
        } catch {
            #if DEBUG
            fatalError("\(error)")
            #else
            Logger.error.log(error)
            return ""
            #endif
        }
    }

    private(set) var underlyingRecord: CKRecord

    var zoneId: CKRecordZone.ID { underlyingRecord.recordID.zoneID }
}

extension Space: Hashable {}

extension Space {
    // swiftlint:disable:next type_name
    typealias ID = String
}

extension Space {
    init(name: String, zoneId: CKRecordZone.ID) {
        let record = CKRecord(
            recordType: RecordType.space.rawValue,
            recordID: CKRecord.ID(
                recordName: UUID().uuidString,
                zoneID: zoneId
            )
        )
        record["name"] = name
        self.underlyingRecord = record
    }

    var isShared: Bool { self.underlyingRecord.share != nil }
}
