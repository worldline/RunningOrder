//
//  Sequence+Extensions.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation

extension Array {
    /// Useful for Binding when waiting for new element to come, but want to create one, so no get to provide
    ///
    /// This variable works only with Bindings that are nil first, then filled when completes and want to add directly the value to the array
    var appendedElement: Element? {
        get {
            return nil
        }

        set {
            if let realNewValue = newValue {
                self.append(realNewValue)
            }
        }
    }
}

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
