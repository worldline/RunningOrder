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

    var videoUrl: URL? {
        didSet {
            let fileManager = FileManager.default
            if let newExtension = videoUrl?.pathExtension, !newExtension.isEmpty {
                videoExtension = newExtension
            } else if let oldUrl = oldValue,
                      let currentExtension = videoExtension,
                      videoUrl == nil,
                      let symbolicUrl = try? Self.symbolicVideoUrl(videoUrl: oldUrl, videoExtension: currentExtension, fileManager: fileManager),
                      fileManager.fileExists(atPath: symbolicUrl.path) {
                try? fileManager.removeItem(at: symbolicUrl)
                self.videoExtension = nil
            }
        }
    }

    private var videoExtension: String?

    var zoneId: CKRecordZone.ID

    init(storyId: Story.ID, zoneId: CKRecordZone.ID, configuration: Configuration = Configuration(), links: [Link] = [], steps: [String] = [], videoUrl: URL? = nil) {
        self.storyId = storyId
        self.configuration = configuration
        self.links = links
        self.steps = steps
        self.videoUrl = videoUrl
        self.zoneId = zoneId
        if let newExtension = videoUrl?.pathExtension, !newExtension.isEmpty {
            self.videoExtension = videoUrl?.pathExtension
        }
    }
}

extension StoryInformation: Equatable {}
extension StoryInformation: Hashable {}

extension StoryInformation {
    static func symbolicVideoUrl(videoUrl: URL, videoExtension: String, fileManager: FileManager) throws -> URL {
        var symbolicUrl = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        symbolicUrl.appendPathComponent(videoUrl.lastPathComponent)
        symbolicUrl.appendPathExtension(videoExtension)

        return symbolicUrl
    }

    func createSymbolicVideoUrlIfNeeded(with fileManager: FileManager) -> URL? {
        guard let videoUrl = videoUrl, let videoExtension = videoExtension else { return nil }

        // If the type corresponding to the pathExtension doesn't exist, it means it's a file from CKAsset,
        // without extension, we then create a symbolic link with the extension
        if UTType(filenameExtension: videoUrl.pathExtension, conformingTo: .movie)?.isDynamic ?? true {
            do {
                let symbolicUrl = try Self.symbolicVideoUrl(videoUrl: videoUrl, videoExtension: videoExtension, fileManager: fileManager)

                if fileManager.fileExists(atPath: symbolicUrl.path) {
                    Logger.debug.log("this symbolic link already exist, no creation")
                } else {
                    try fileManager.createSymbolicLink(at: symbolicUrl, withDestinationURL: videoUrl)
                }

                return symbolicUrl
            } catch {
                Logger.error.log(error)
                return nil
            }
        } else {
            return videoUrl
        }
    }
}

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
        let decoder: JSONDecoder = JSONDecoder()
        self.links = try decoder.decode([Link].self, from: linksData)

        let videoAsset: CKAsset? = try? record.property("video")
        self.videoUrl = videoAsset?.fileURL
        self.videoExtension = try? record.property("videoExtension")

        self.zoneId = record.recordID.zoneID

        self.configuration = .init(environments: environments, mocks: mocks, features: features, indicators: indicators, identifiers: identifiers)
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

        let encoder: JSONEncoder = JSONEncoder()

        do {
            storyInformationRecord["links"] = try encoder.encode(self.links)
        } catch {
            storyInformationRecord["links"] = try? encoder.encode([Link]())
            Logger.error.log(error)
        }

        if let videoUrl = self.videoUrl {
            storyInformationRecord["video"] = CKAsset(fileURL: videoUrl)
            storyInformationRecord["videoExtension"] = self.videoExtension
        } else {
            storyInformationRecord["video"] = nil
            storyInformationRecord["videoExtension"] = nil

        }

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
