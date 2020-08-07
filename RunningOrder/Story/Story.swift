//
//  Story.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation

struct Story {
    var name: String
    let ticketReference: String
    let epic: String

    var configuration: Configuration
    var link: Link
}

extension Story: Equatable { }
extension Story: Hashable { }
