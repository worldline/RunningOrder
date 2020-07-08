//
//  Story.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation

struct Story {
    let name: String
    let ticketReference: String
}

extension Story: Equatable { }
extension Story: Hashable { }
