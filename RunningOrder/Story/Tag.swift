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

    init(_ text: String, color: Color) {
        self.text = text
        self.color = color
    }

    var body: some View {
        Text(text)
            .foregroundColor(Color.white)
            .padding(.horizontal, 4)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 2))
    }
}

struct Tag_Previews: PreviewProvider {
    static var previews: some View {
        Tag("A Tag", color: Color("blue1"))
    }
}
