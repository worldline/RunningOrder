//
//  StyledFocusableTextField.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 24/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

/// A styled focusable version of a Textfield based on NSTextField
struct StyledFocusableTextField: View {

    let placeholder: String

    @State private var isFocused = false
    @Binding var value: String

    private var borderOpacity: Double { isFocused ? 1 : 0 }

    let onCommit: () -> Void

    /// - Parameters:
    ///   - placeholder: the textfield placeholder
    ///   - value: the binding to the textfield value
    ///   - onCommit: the action to perform when the user hits the return key or when the component looses the focus
    init(_ placeholder: String, value: Binding<String>, onCommit: @escaping () -> Void) {
        self.placeholder = placeholder
        self._value = value
        self.onCommit = onCommit
    }

    var body: some View {
        FocusableTextField(placeholder: placeholder, value: $value, isFocused: $isFocused, onCommit: onCommit)
            .padding(5)
            // on focus background
            .background(RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(NSColor.textBackgroundColor).opacity(borderOpacity))
                            .animation(.linear)
            )
            // on focus border
            .overlay(RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.accentColor, lineWidth: 1.0, antialiased: true)
                        .opacity(borderOpacity)
                        .animation(.easeInOut)
            )
            .focusable()
    }
}

struct FocusableTextField_Previews: PreviewProvider {
    static var previews: some View {
        StyledFocusableTextField("Placeholder", value: .constant(""), onCommit: {})
    }
}
