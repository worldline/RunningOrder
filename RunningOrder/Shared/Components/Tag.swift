//
//  Tag.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 30/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct Tag: View {

    let text: String
    let color: Color
    let foregroundTextColor: Color

    init(_ text: String, color: Color, foregroundTextColor: Color = Color.white) {
        self.text = text
        self.color = color
        self.foregroundTextColor = foregroundTextColor
    }

    var body: some View {
        Text(text)
            .foregroundColor(foregroundTextColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

struct Tag_Previews: PreviewProvider {
    static var previews: some View {
        Tag("A Tag", color: Color(identifier: .holidayBlue))
    }
}
