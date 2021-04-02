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

@propertyWrapper struct Stored<StoredType: Storable> {
    let fileName: String
    let directory: FileManager.SearchPathDirectory

    var wrappedValue: StoredType? {
        get { get() }

        set {
            if let newValue = newValue {
                set(newValue)
            } else {
                delete()
            }
        }
    }

    private var fileURL: URL? {
        FileManager.default.urls(for: directory, in: .userDomainMask)
            .first?
            .appendingPathComponent(Bundle.main.bundleIdentifier ?? "")
            .appendingPathComponent(fileName)
    }

    private func get() -> StoredType? {
        guard let fileURL = fileURL else { return nil }

        do {
            let data = try Data(contentsOf: fileURL)

            return try StoredType.decodeData(storedData: data)
        } catch {
            Logger.warning.log("\(StoredType.self) are missing or corrupted\n\(error)")

            return nil
        }
    }

    private func set(_ value: StoredType) {
        guard let fileURL = fileURL else { return }

        do {
            let data = try value.encodeToData()

            try data.write(to: fileURL)
        } catch {
            Logger.warning.log("\(StoredType.self) encoding failed\n\(error)")
        }
    }

    private func delete() {
        guard let fileURL = fileURL else { return }

        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            Logger.warning.log("\(StoredType.self) deleting failed\n\(error)")
        }
    }
}
