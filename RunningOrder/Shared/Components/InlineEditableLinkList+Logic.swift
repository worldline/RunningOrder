//
//  InlineEditableLinkList+Logic.swift
//  RunningOrder
//
//  Created by Loic B on 16/04/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

extension InlineEditableLinkList {
    final class Logic: ObservableObject {
        @Binding var values: [LinkEntity]

        internal init(values: Binding<[LinkEntity]>) {
            self._values = values
        }

        func addLinkTextField() {
            values.append(LinkEntity(label: "", url: ""))
        }

        func deleteTextField(at index: Int) {
            //sanity check to prevent some out of bounds exception
            guard index < values.count else { return }
            _ = values.remove(at: index)
        }
    }
}
