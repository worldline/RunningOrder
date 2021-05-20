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
