//
//  Space.swift
//  RunningOrder
//
//  Created by Clément Nonn on 21/09/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import CloudKit

struct Space {
    var id: ID { underlyingRecord.recordID.recordName }
    var name: String {
        do {
            return try underlyingRecord.property("name")
        } catch {
            Logger.error.log(error)
            return ""
        }
    }

    private(set) var underlyingRecord: CKRecord
}

extension Space {
    // swiftlint:disable:next type_name
    typealias ID = String
}

extension Space {
    init(name: String) {
        let id = CKRecord.ID(recordName: UUID().uuidString, zoneID: CloudKitContainer.shared.sharedZoneId)
        let record = CKRecord(recordType: RecordType.space.rawValue, recordID: id)
        record["name"] = name
        self.underlyingRecord = record
    }

    var isShared: Bool { self.underlyingRecord.share != nil }
}
