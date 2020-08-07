//
//  Lien.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 07/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation

struct Link {
    var specifications: [String] = []
    var zeplins: [String] = []
}

extension Link: Equatable { }
extension Link: Hashable { }
