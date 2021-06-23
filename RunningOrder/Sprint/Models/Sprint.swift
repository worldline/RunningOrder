//
//  Sprint.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import CloudKit.CKRecordZone

struct Sprint {
    let spaceId: Space.ID
    let number: Int
    let name: String
    let colorIdentifier: String
    var closed: Bool

    let zoneId: CKRecordZone.ID
}

extension Sprint {
    // swiftlint:disable:next type_name
    typealias ID = String
    var id: ID { return "\(self.name)\(self.number)" }
}

extension Sprint: Equatable { }
extension Sprint: Hashable { }

extension Sprint: Codable {
    enum CodingKeys: String, CodingKey {
        case spaceId
        case number
        case name
        case colorIdentifier
        case closed
        case zoneId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.spaceId = try container.decode(Space.ID.self, forKey: .spaceId)
        self.number = try container.decode(Int.self, forKey: .number)
        self.name = try container.decode(String.self, forKey: .name)
        self.colorIdentifier = try container.decode(String.self, forKey: .colorIdentifier)
        self.closed = try container.decode(Bool.self, forKey: .closed)
        self.zoneId = try container.decode(ObjectCodableWrapper<CKRecordZone.ID>.self, forKey: .zoneId).wrappedValue
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(spaceId, forKey: .spaceId)
        try container.encode(number, forKey: .number)
        try container.encode(name, forKey: .name)
        try container.encode(colorIdentifier, forKey: .colorIdentifier)
        try container.encode(closed, forKey: .closed)
        try container.encode(ObjectCodableWrapper<CKRecordZone.ID>(wrappedValue: zoneId), forKey: .zoneId)
    }
}
