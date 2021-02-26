//
//  Configuration.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 07/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation

struct Configuration {
    var environments: [String] = []
    var mocks: [String] = []
    var features: [String] = []
    var indicators: [String] = []
    var identifiers: [String] = []
    var links: LinkEntity = LinkEntity()
}

extension Configuration: Equatable { }
extension Configuration: Hashable { }
