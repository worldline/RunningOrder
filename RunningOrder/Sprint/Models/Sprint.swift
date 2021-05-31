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

    var zoneId: CKRecordZone.ID
}

extension Sprint {
    // swiftlint:disable:next type_name
    typealias ID = String
    var id: ID { return "\(self.name)\(self.number)" }
}

extension Sprint: Equatable { }
extension Sprint: Hashable { }
