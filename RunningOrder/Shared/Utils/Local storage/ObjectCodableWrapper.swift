//
//  ObjectCodableWrapper.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/06/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation

struct ObjectCodableWrapper<ObjectType: NSObject & NSSecureCoding>: Codable {
    var wrappedValue: ObjectType

    init(wrappedValue: ObjectType) {
        self.wrappedValue = wrappedValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        let storedData = try container.decode(Data.self)

        guard let object = try NSKeyedUnarchiver.unarchivedObject(ofClass: ObjectType.self, from: storedData) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "couldn't unarchive the data object")
        }

        self.wrappedValue = object
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        let data = try NSKeyedArchiver.archivedData(withRootObject: self.wrappedValue, requiringSecureCoding: true)
        try container.encode(data)
    }
}

extension ObjectCodableWrapper: Hashable where ObjectType: Hashable {
    func hash(into hasher: inout Hasher) {
        self.wrappedValue.hash(into: &hasher)
    }
}
