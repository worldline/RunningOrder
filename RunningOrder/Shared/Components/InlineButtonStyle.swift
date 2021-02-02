//
//  InlineButtonStyle.swift
//  RunningOrder
//
//  Created by Clément Nonn on 02/02/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI

struct InlineButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .frame(width: 17, height: 17)
            .padding(.horizontal, 10)
            .buttonStyle(PlainButtonStyle())
    }
}
