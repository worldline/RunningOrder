//
//  StoryInformation+CloudKit.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 20/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
//import CloudKit
//
//extension StoryInformation: CKRecordable {
//
//    init(from record: CKRecord) throws {
//        let storyReference: CKRecord.Reference = try record.property("storyId")
//        self.storyId = storyReference.recordID.recordName
//
//        self.steps = try record.property("steps")
//        let environments: [String] = try record.property("environments")
//        let mocks: [String] = try record.property("mocks")
//        let features: [String] = try record.property("features")
//        let indicators: [String] = try record.property("indicators")
//        let identifiers: [String] = try record.property("identifiers")
//        let linkLabels: [String] = try record.property("links")
//
//        let videoAsset: CKAsset? = try? record.property("video")
//        self.videoUrl = videoAsset?.fileURL
//        self.videoExtension = try? record.property("videoExtension")
//
//        self.links = linkLabels.map { Link.init(value: $0) }
//
//        self.configuration = .init(environments: environments, mocks: mocks, features: features, indicators: indicators, identifiers: identifiers)
//    }
//
//    func encode(zoneId: CKRecordZone.ID) -> CKRecord {
//        let storyInformationRecord = CKRecord(recordType: RecordType.storyInformation.rawValue, recordID: recordId(zoneId: zoneId))
//
//        storyInformationRecord["storyId"] = CKRecord.Reference(recordID: storyRecordId(zoneId: zoneId), action: .deleteSelf)
//        storyInformationRecord.parent = CKRecord.Reference(recordID: storyRecordId(zoneId: zoneId), action: .none)
//        storyInformationRecord["steps"] = self.steps
//
//        // Configuration
//
//        storyInformationRecord["environments"] = self.configuration.environments
//        storyInformationRecord["mocks"] = self.configuration.mocks
//        storyInformationRecord["features"] = self.configuration.features
//        storyInformationRecord["indicators"] = self.configuration.indicators
//        storyInformationRecord["identifiers"] = self.configuration.identifiers
//
//        // Links : for now as a link label is only the url string representation we can only store all the labels, will change in the future
//
//        storyInformationRecord["links"] = self.links.map { $0.label }
//
//        if let videoUrl = self.videoUrl {
//            storyInformationRecord["video"] = CKAsset(fileURL: videoUrl)
//            storyInformationRecord["videoExtension"] = self.videoExtension
//        }
//
//        return storyInformationRecord
//    }
//
//    private func recordId(zoneId: CKRecordZone.ID) -> CKRecord.ID {
//        return CKRecord.ID(recordName: Self.recordName(for: self.storyId), zoneID: zoneId) // we construct an unique ID based on the storyID
//    }
//
//    static func recordName(for storyId: String) -> String {
//        return "si-\(storyId)"
//    }
//
//    private func storyRecordId(zoneId: CKRecordZone.ID) -> CKRecord.ID {
//        return CKRecord.ID(recordName: self.storyId, zoneID: zoneId)
//    }
//}
