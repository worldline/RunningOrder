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

        case systemRed
        case systemGreen
        case systemBlue
        case systemOrange
        case systemYellow
        case systemBrown
        case systemPink
        case systemPurple
        case systemTeal
        case systemIndigo

        var system: Color? {
            switch self {
            case .systemRed:
                return Color.red
            case .systemGreen:
                return Color.green
            case .systemBlue:
                return Color.blue
            case .systemOrange:
                return Color.orange
            case .systemYellow:
                return Color.yellow
            case .systemBrown:
                return Color(NSColor.systemBrown)
            case .systemPink:
                return Color.pink
            case .systemPurple:
                return Color.purple
            case .systemTeal:
                return Color(NSColor.systemTeal)
            case .systemIndigo:
                return Color(NSColor.systemIndigo)
            default:
                return nil
            }
        }
    }

    init(identifier: Color.Identifier) {
        if let systemColor = identifier.system {
            self = systemColor
        } else {
            self.init(identifier.rawValue)
        }
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
            systemGreen,
            systemBlue,
            systemOrange,
            systemYellow,
            systemBrown,
            systemPink,
            systemPurple,
            systemTeal,
            systemIndigo,
            systemRed,

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
