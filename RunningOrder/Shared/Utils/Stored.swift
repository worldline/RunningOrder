//
//  Stored.swift
//  RunningOrder
//
//  Created by Clément Nonn on 02/04/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation

protocol Storable {
    static func decodeData(storedData: Data) throws -> Self

    func encodeToData() throws -> Data
}

extension Data: Storable {
    static func decodeData(storedData: Data) throws -> Data {
        return storedData
    }

    func encodeToData() throws -> Data {
        return self
    }
}

enum StoreError: Error {
    case fileNotCreated(URL)
}

@propertyWrapper struct Stored<StoredType: Storable> {
    let fileManager: FileManager
    let fileName: String
    let directory: FileManager.SearchPathDirectory

    var wrappedValue: StoredType? {
        get {
            guard let fileURL = fileURL else { return nil }

            do {
                let data = try Data(contentsOf: fileURL)

                return try StoredType.decodeData(storedData: data)
            } catch {
                Logger.warning.log("\(StoredType.self) are missing or corrupted\n\(error)")

                return nil
            }
        }

        set {
            guard let fileURL = fileURL else {
                Logger.error.log("\(StoredType.self) are missing a proper url")
                return
            }

            do {
                if let newValue = newValue {
                    let data = try newValue.encodeToData()

                    if !fileManager.fileExists(atPath: fileURL.path) {
                        let creationSucceed = fileManager.createFile(atPath: fileURL.path, contents: data, attributes: nil)
                        if !creationSucceed {
                            throw StoreError.fileNotCreated(fileURL)
                        }
                    } else {
                        try data.write(to: fileURL)
                    }
                } else {
                    try fileManager.removeItem(at: fileURL)
                }
            } catch {
                Logger.warning.log("\(StoredType.self) set failed\n\(error)")
            }
        }
    }

    private var fileURL: URL? {
        fileManager.urls(for: directory, in: .userDomainMask)
            .first?
            .appendingPathComponent(fileName)
    }

    init(fileManager: FileManager = .default, fileName: String, directory: FileManager.SearchPathDirectory) {
        self.fileName = fileName
        self.directory = directory
        self.fileManager = fileManager
    }
}
