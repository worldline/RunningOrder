//
//  Sprint.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import SwiftUI

struct Sprint {

    let number: Int
    let name: String
    let colorIdentifier: String
}

extension Sprint: Identifiable {
    typealias ID = String
    
    var id: ID { return "\(self.name)\(self.number)" }
}

extension Sprint: Equatable { }
extension Sprint: Hashable { }
