//
//  InlineEditableLink+Logic.swift
//  RunningOrder
//
//  Created by Loic B on 21/04/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

extension InlineEditableLink {
    final class Logic: ObservableObject {
        @Binding var value: Link

        var isFieldEmpty: Bool {
            return value.url.isEmpty || value.label.isEmpty
        }

        init(value: Binding<Link>) {
            self._value = value
        }

        func formatURL(content: String) -> String {
            var url = content
            if !value.url.contains("https://") && !value.url.contains("http://") {
                url.insert(contentsOf: "https://", at: value.url.startIndex)
            }
            return url
        }
    }
}
