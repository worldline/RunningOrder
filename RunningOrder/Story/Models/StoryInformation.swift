//
//  StoryInformations.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 12/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import UniformTypeIdentifiers

struct StoryInformation {
    let storyId: Story.ID

    var configuration: Configuration
    var links: [Link]

    var steps: [String]

    var comment: String

    var zoneId: CKRecordZone.ID

    init(storyId: Story.ID, zoneId: CKRecordZone.ID, configuration: Configuration = Configuration(), links: [Link] = [], steps: [String] = [], comment: String = "") {
        self.storyId = storyId
        self.configuration = configuration
        self.links = links
        self.steps = steps
        self.comment = comment
        self.zoneId = zoneId
    }
}

extension StoryInformation: Equatable {}
extension StoryInformation: Hashable {}

import CloudKit

// Extension here to access to a private property of the struct.
extension StoryInformation: CKRecordable {
    init(from record: CKRecord) throws {
        let storyReference: CKRecord.Reference = try record.property("storyId")
        self.storyId = storyReference.recordID.recordName

        self.steps = try record.property("steps")
        let environments: [String] = try record.property("environments")
        let mocks: [String] = try record.property("mocks")
        let features: [String] = try record.property("features")
        let indicators: [String] = try record.property("indicators")
        let identifiers: [String] = try record.property("identifiers")

        let linksData: Data = try record.property("links")
        self.links = try JSONDecoder.default.decode([Link].self, from: linksData)

        self.comment = (try? record.property("comment")) ?? ""

        self.zoneId = record.recordID.zoneID

        self.configuration = .init(
            environments: environments,
            mocks: mocks,
            features: features,
            indicators: indicators,
            identifiers: identifiers
        )
    }

    func encode() -> CKRecord {
        let storyInformationRecord = CKRecord(recordType: RecordType.storyInformation.rawValue, recordID: recordId(zoneId: zoneId))

        storyInformationRecord["storyId"] = CKRecord.Reference(recordID: storyRecordId(zoneId: zoneId), action: .deleteSelf)
        storyInformationRecord.parent = CKRecord.Reference(recordID: storyRecordId(zoneId: zoneId), action: .none)
        storyInformationRecord["steps"] = self.steps

        // Configuration

        storyInformationRecord["environments"] = self.configuration.environments
        storyInformationRecord["mocks"] = self.configuration.mocks
        storyInformationRecord["features"] = self.configuration.features
        storyInformationRecord["indicators"] = self.configuration.indicators
        storyInformationRecord["identifiers"] = self.configuration.identifiers

        // Links : for now as a link label is only the url string representation we can only store all the labels, will change in the future

        do {
            storyInformationRecord["links"] = try JSONEncoder.default.encode(self.links)
        } catch {
            storyInformationRecord["links"] = try? JSONEncoder.default.encode([Link]())
            Logger.error.log(error)
        }

        storyInformationRecord["comment"] = self.comment

        return storyInformationRecord
    }

    private func recordId(zoneId: CKRecordZone.ID) -> CKRecord.ID {
        return CKRecord.ID(recordName: Self.recordName(for: self.storyId), zoneID: zoneId) // we construct an unique ID based on the storyID
    }

    static func recordName(for storyId: String) -> String {
        return "si-\(storyId)"
    }

    private func storyRecordId(zoneId: CKRecordZone.ID) -> CKRecord.ID {
        return CKRecord.ID(recordName: self.storyId, zoneID: zoneId)
    }
}

extension StoryInformation: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let record = try container.decode(ObjectCodableWrapper<CKRecord>.self).wrappedValue
        try self.init(from: record)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(ObjectCodableWrapper<CKRecord>(wrappedValue: self.encode()))
    }
}
