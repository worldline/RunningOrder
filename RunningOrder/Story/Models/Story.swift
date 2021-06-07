//
//  Story.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import CloudKit.CKRecordZone

struct Story {
    let sprintId: Sprint.ID
    let name: String
    let ticketReference: String
    let epic: String

    let creatorReference: User.Reference?
    let zoneId: CKRecordZone.ID
}

extension Story {
    // swiftlint:disable:next type_name
    typealias ID = String
    var id: String { ticketReference }
}
extension Story: Equatable { }
extension Story: Hashable { }

extension Story: Codable {
    enum CodingKeys: String, CodingKey {
        case sprintId
        case name
        case ticketReference
        case epic
        case creatorReference
        case zoneId
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        sprintId = try container.decode(Sprint.ID.self, forKey: .sprintId)
        name = try container.decode(String.self, forKey: .name)
        ticketReference = try container.decode(String.self, forKey: .ticketReference)
        epic = try container.decode(String.self, forKey: .epic)
        if let userRecordId = try container.decodeIfPresent(ObjectCodableWrapper<CKRecord.ID>.self, forKey: .creatorReference)?.wrappedValue {
            creatorReference = User.Reference(recordId: userRecordId)
        } else {
            creatorReference = nil
        }
        zoneId = try container.decode(ObjectCodableWrapper<CKRecordZone.ID>.self, forKey: .zoneId).wrappedValue
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sprintId, forKey: .sprintId)
        try container.encode(name, forKey: .name)
        try container.encode(ticketReference, forKey: .ticketReference)
        try container.encode(epic, forKey: .epic)
        if let userReference = creatorReference {
            try container.encode(ObjectCodableWrapper<CKRecord.ID>(wrappedValue: userReference.recordId), forKey: .creatorReference)
        }

        try container.encode(ObjectCodableWrapper<CKRecordZone.ID>(wrappedValue: zoneId), forKey: .zoneId)
    }
}
