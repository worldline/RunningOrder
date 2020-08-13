//
//  Sprint.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation

struct Sprint {

    let number: Int
    let name: String
    let colorIdentifier: String
}

extension Sprint {
    // swiftlint:disable:next type_name
    typealias ID = String
    var id: ID { return "\(self.name)\(self.number)" }
}

extension Sprint: Equatable { }
extension Sprint: Hashable { }
