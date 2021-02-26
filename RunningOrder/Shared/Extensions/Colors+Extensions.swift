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

        case anotherBlue = "epics/anotherBlue"
        case blue = "epics/blue"
        case emeraldGreen = "epics/emeraldGreen"
        case gray = "epics/gray"
        case grayBlue = "epics/grayBlue"
        case green = "epics/green"
        case maroon = "epics/maroon"
        case orange = "epics/orange"
        case peach = "epics/peach"
        case pink = "epics/pink"
        case purple = "epics/purple"
        case red = "epics/red"
        case seaBlue = "epics/seaBlue"
        case yellow = "epics/yellow"
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

    static var epicColors: [Self] {
        [
            anotherBlue,
            blue,
            emeraldGreen,
            gray,
            grayBlue,
            green,
            maroon,
            orange,
            peach,
            pink,
            purple,
            red,
            seaBlue,
            yellow
        ]
    }
}
