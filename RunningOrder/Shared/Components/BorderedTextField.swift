//
//  BorderedTextField.swift
//  RunningOrder
//
//  Created by Loic B on 16/04/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI

struct BorderedTextField: View {
    let placeholder: String
    @Binding var value: String

    var body: some View {
        FocusableTextField(placeholder: placeholder, value: $value, isFocused: .constant(false), onCommit: {})
            .padding(5)
            // on focus background
            .background(RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(NSColor.textBackgroundColor))
            )
            // on focus border
            .overlay(RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.accentColor, lineWidth: 1.0, antialiased: true)
            )
    }
}

struct BorderedTextField_Previews: PreviewProvider {
    static var previews: some View {
        BorderedTextField(placeholder: "Label", value: .constant(""))
            .padding(10)
    }
}
