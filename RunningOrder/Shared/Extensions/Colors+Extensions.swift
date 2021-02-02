//
//  Colors.swift
//  RunningOrder
//
//  Created by Clément Nonn on 02/10/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import SwiftUI

extension Color {
    enum Identifier: String {
        case snowbank
        case holidayBlue = "holiday blue"
        case elfGreen = "elf green"
    }

    init(identifier: Color.Identifier) {
        self.init(identifier.rawValue)
    }
}

extension Color.Identifier: CaseIterable { }

extension Color.Identifier {
    static func randomElement() -> Self {
        return Self.allCases.randomElement()!
    }

    static var sprintColors: [Self] { [.holidayBlue, .elfGreen] }
}
