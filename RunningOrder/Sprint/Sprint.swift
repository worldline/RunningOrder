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

    var stories: [Story]
}

extension Sprint: Equatable { }
extension Sprint: Hashable { }
