//
//  EpicColor.swift
//  RunningOrder
//
//  Created by Clément Nonn on 12/03/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI

private struct EpicColorKey: EnvironmentKey {
    static let defaultValue: Color = Color(identifier: .holidayBlue)
}

extension EnvironmentValues {
    var epicColor: Color {
        get { self[EpicColorKey.self] }
        set { self[EpicColorKey.self] = newValue }
    }
}

extension View {
    func epicColor(_ myCustomValue: Color) -> some View {
        environment(\.epicColor, myCustomValue)
    }
}
