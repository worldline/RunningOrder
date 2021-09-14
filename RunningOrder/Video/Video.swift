//
//  Video.swift
//  RunningOrder
//
//  Created by Clément Nonn on 13/07/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation
import UniformTypeIdentifiers
import AVFoundation
import CloudKit

struct Video {
    let id: String
    var name: String
    let url: URL
    let extensionString: String

    let storyId: Story.ID
    let zoneId: CKRecordZone.ID
}

enum VideoError: Error {
    case fileAlreadyExist
    case internalError(Error)
}

extension Video {
    init(id: UUID = UUID(), name: String, url: URL, storyId: Story.ID, zoneId: CKRecordZone.ID) {
        self.id = id.uuidString
        self.name = name
        self.url = url
        self.extensionString = url.pathExtension
        self.storyId = storyId
        self.zoneId = zoneId
    }

    func deleteFile(fileManager: FileManager = .default) throws {
        try fileManager.removeItem(at: url)

        let symbolic = try Self.symbolicVideoUrl(videoUrl: url, videoExtension: extensionString, fileManager: fileManager)
        if fileManager.isSymbolicFileExist(at: symbolic.path) {
            try fileManager.removeItem(at: symbolic)
        }
    }

    func downloadUrl(fileManager: FileManager = .default) -> URL {
        do {
            let downloadFolder = try fileManager.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

            let fileName = name.hasSuffix(".\(extensionString)") ? name : "\(name).\(extensionString)"
            return downloadFolder.appendingPathComponent(fileName)
        } catch {
            Logger.error.log(error)
            return URL(string: "")!
        }
    }

    func save(overridingExistingFile: Bool = false, fileManager: FileManager = .default) throws {
        let fileUrl = downloadUrl(fileManager: fileManager)

        switch (fileManager.fileExists(atPath: fileUrl.path), overridingExistingFile) {
        case (true, true):
            try fileManager.removeItem(at: fileUrl)
        case (true, false):
            throw VideoError.fileAlreadyExist
        case (false, _):
            break
        }

        try fileManager.copyItem(at: url, to: fileUrl)
    }

    var avPlayer: AVPlayer? {
        if let videoUrl = self.createSymbolicVideoUrlIfNeeded(with: .default) {
            return AVPlayer(playerItem: AVPlayerItem(asset: AVAsset(url: videoUrl)))
        } else {
            return nil
        }
    }
}

extension Video {
    static func symbolicVideoUrl(videoUrl: URL, videoExtension: String, fileManager: FileManager) throws -> URL {
        var symbolicUrl = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        symbolicUrl.appendPathComponent(videoUrl.lastPathComponent)
        symbolicUrl.appendPathExtension(videoExtension)

        return symbolicUrl
    }

    func createSymbolicVideoUrlIfNeeded(with fileManager: FileManager) -> URL? {
        guard fileManager.fileExists(atPath: url.path) else {
            if let symbolicUrl = try? Self.symbolicVideoUrl(videoUrl: url, videoExtension: extensionString, fileManager: fileManager),
               fileManager.isSymbolicFileExist(at: symbolicUrl.path) {
                try? fileManager.removeItem(at: symbolicUrl)
            }

            return nil
        }

        // If the type corresponding to the pathExtension doesn't exist, it means it's a file from CKAsset,
        // without extension, we then create a symbolic link with the extension
        if UTType(filenameExtension: url.pathExtension, conformingTo: .movie)?.isDynamic ?? true {
            do {
                let symbolicUrl = try Self.symbolicVideoUrl(videoUrl: url, videoExtension: extensionString, fileManager: fileManager)

                if fileManager.fileExists(atPath: symbolicUrl.path) {
                    Logger.debug.log("this symbolic link already exist, no creation")
                } else {
                    // Here, the file doesn't exist at the symbolic destination.
                    // It could be either the symbolic link itself doesn't exist, or the file at the destination that doesn't exist anymore. in that case, we remove the link to recreate the link with the proper destination
                    if fileManager.isSymbolicFileExist(at: symbolicUrl.path) {
                        try fileManager.removeItem(at: symbolicUrl)
                    }

                    // then we create it anyway
                    try fileManager.createSymbolicLink(at: symbolicUrl, withDestinationURL: url)
                }

                return symbolicUrl
            } catch {
                Logger.error.log(error)
                return nil
            }
        } else {
            return url
        }
    }
}

extension Video: CKRecordable {
    init(from record: CKRecord) throws {
        self.name = try record.property("name")
        let videoAsset: CKAsset = try record.property("video")
        guard let fileUrl = videoAsset.fileURL else {
            throw BasicError.noValue
        }
        self.url = fileUrl
        self.extensionString = try record.property("videoExtension")

        self.id = record.recordID.recordName
        self.zoneId = record.recordID.zoneID
        let storyReference: CKRecord.Reference = try record.property("storyId")
        self.storyId = storyReference.recordID.recordName
    }

    func encode() -> CKRecord {
        let record = CKRecord(
            recordType: RecordType.video.rawValue,
            recordID: CKRecord.ID(
                recordName: id,
                zoneID: zoneId
            )
        )
        record["name"]  = name
        record["videoExtension"] = extensionString
        record["video"] = CKAsset(fileURL: url)
        record["storyId"] = CKRecord.Reference(
            recordID: CKRecord.ID(
                recordName: storyId,
                zoneID: zoneId),
            action: .deleteSelf
        )

        return record
    }
}

extension Video: Codable {
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
