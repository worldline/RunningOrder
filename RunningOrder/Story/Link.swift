//
//  Lien.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 07/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation

struct Link {
    var label: String
    var url: URL?

    init(value: String) {
        self.url = URL(string: value)
        self.label = value
    }
}

extension Link: Equatable { }
extension Link: Hashable { }
