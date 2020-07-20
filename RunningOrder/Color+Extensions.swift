//
//  Color+Extensions.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 20/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import SwiftUI

extension Color {
    init(_ hexValue: UInt32, opacity: Double = 1.0) {
        let red = Double((hexValue & 0xff0000) >> 16) / 255.0
        let green = Double((hexValue & 0xff00) >> 8) / 255.0
        let blue = Double((hexValue & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
