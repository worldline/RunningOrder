//
//  TextfieldEditingStringHandler.swift
//  RunningOrder
//
//  Created by Clément Nonn on 12/03/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation

protocol TextfieldEditingStringHandler: AnyObject {
    func fieldEditingChanged(valueKeyPath: ReferenceWritableKeyPath<Self, String>) -> (Bool) -> Void
}

extension TextfieldEditingStringHandler {
    private func trimValue(valueKeyPath: ReferenceWritableKeyPath<Self, String>) {
        self[keyPath: valueKeyPath] = self[keyPath: valueKeyPath].trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func fieldEditingChanged(valueKeyPath: ReferenceWritableKeyPath<Self, String>) -> (Bool) -> Void {
        return { isBeginning in
            if !isBeginning {
                self.trimValue(valueKeyPath: valueKeyPath)
            }
        }
    }
}
