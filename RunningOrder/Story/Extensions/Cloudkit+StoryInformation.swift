//
//  Cloudkit+StoryInformation.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 20/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import CloudKit

extension StoryInformation: CKRecordable {

    init(from record: CKRecord) throws {
        let storyReference: CKRecord.Reference = try record.property("storyId")
        self.storyId = storyReference.recordID.recordName

        self.steps = try record.property("steps")
        let environments: [String] = try record.property("steps")
        let mocks: [String] = try record.property("mocks")
        let features: [String] = try record.property("features")
        let indicators: [String] = try record.property("indicators")
        let identifiers: [String] = try record.property("identifiers")
        let linkLabels: [String] = try record.property("links")

        self.links = linkLabels.map { Link.init(value: $0) }
        self.configuration = .init(environments: environments, mocks: mocks, features: features, indicators: indicators, identifiers: identifiers)
    }

    func encode(zoneId: CKRecordZone.ID) -> CKRecord {
        let storyInformationRecord = CKRecord(recordType: RecordType.storyInformation.rawValue, recordID: recordId(zoneId: zoneId))

        storyInformationRecord["storyId"] = CKRecord.Reference(recordID: storyRecordId(zoneId: zoneId), action: .deleteSelf) as CKRecordValue
        storyInformationRecord["steps"] = self.steps as CKRecordValue

        // Configuration

        storyInformationRecord["environments"] = self.configuration.environments as CKRecordValue
        storyInformationRecord["mocks"] = self.configuration.mocks as CKRecordValue
        storyInformationRecord["features"] = self.configuration.features as CKRecordValue
        storyInformationRecord["indicators"] = self.configuration.indicators as CKRecordValue
        storyInformationRecord["identifiers"] = self.configuration.identifiers as CKRecordValue

        // Links : for now as a link label is only the url string representation we can only store all the labels, will change in the future

        storyInformationRecord["links"] = self.links.map { $0.label } as CKRecordValue

        return storyInformationRecord
    }

    private func recordId(zoneId: CKRecordZone.ID) -> CKRecord.ID {
        return CKRecord.ID(recordName: "si-\(self.storyId)", zoneID: zoneId) // we construct an unique ID based on the storyID
    }

    private func storyRecordId(zoneId: CKRecordZone.ID) -> CKRecord.ID {
        return CKRecord.ID(recordName: self.storyId, zoneID: zoneId)
    }
}
