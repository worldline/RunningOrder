//
//  FocusableTextField.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 24/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct FocusableTextField: View {

    let placeholder: String

    @State private var isFocused = false
    @Binding var value: String

    let onCommit: () -> Void

    init(_ placeholder: String, value: Binding<String>, onCommit: @escaping () -> Void) {
        self.placeholder = placeholder
        self._value = value
        self.onCommit = onCommit
    }

    var body: some View {
        FocusableNSTextFieldRepresentable(placeholder: placeholder, value: $value, isFocused: $isFocused, onCommit: onCommit)
            .padding(.all, 5)
            // on focus background
            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.white.opacity(isFocused ? 1 : 0)))
            // on focus border
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.accentColor, lineWidth: 1.0, antialiased: true).opacity(isFocused ? 1 : 0))
            .animation(.easeIn)
            .focusable()
    }
}

struct FocusableTextField_Previews: PreviewProvider {
    static var previews: some View {
        FocusableTextField("Placeholder", value: .constant(""), onCommit: {})
    }
}
