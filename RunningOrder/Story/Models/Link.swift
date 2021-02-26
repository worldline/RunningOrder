//
//  Lien.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 07/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation

struct LinkEntity {
    var label: String
    var url: String

    init(label: String = "", url: String = "") {
        self.label = label
        self.url = url
    }

    var formattedURL: URL? {
        guard let url = URL(string: self.url) else { return nil }

        return url
    }
}

extension LinkEntity: Equatable { }
extension LinkEntity: Hashable { }
