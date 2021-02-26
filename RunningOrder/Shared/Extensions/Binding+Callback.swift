//
//  Binding+Callback.swift
//  RunningOrder
//
//  Created by Clément Nonn on 19/02/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI

extension Binding {
    init<Wrapped>(callback: @escaping (Wrapped) -> Void) where Value == Wrapped? {
        self.init(
            get: { return nil },
            set: { newValue in
                if let newValue = newValue {
                    callback(newValue)
                }
            }
        )
    }
}
