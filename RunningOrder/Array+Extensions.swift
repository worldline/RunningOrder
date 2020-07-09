//
//  Array+Extensions.swift
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
