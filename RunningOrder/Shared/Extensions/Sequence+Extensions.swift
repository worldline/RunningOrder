//
//  Sequence+Extensions.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation

extension Dictionary {
    func combine<OtherElement, FinalElement>(with other: [Self.Key: OtherElement], mergingHandler: (Self.Value?, OtherElement?) -> FinalElement) -> [Self.Key: FinalElement] {
        var combined = [Key: FinalElement]()

        for (key, value) in self {
            combined[key] = mergingHandler(value, other[key])
        }

        let toAdd = other.filter { !combined.keys.contains($0.key) }

        for (key, value) in toAdd {
            combined[key] = mergingHandler(nil, value)
        }

        return combined
    }
}
