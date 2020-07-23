//
//  InlineTexField.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 20/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI
import AppKit

/// Display an inline editable list of string element
struct InlineEditableList: View { // Change name ???

    let title: String

    let placeholder: String

    @Binding var values: [String]
    @State private var hovered = false

    var body: some View {
        VStack {

            HStack {
                Text(title).foregroundColor(.gray).padding(.all, 6)
                Spacer()
                if hovered {
                    AddButton(action: addTextfieldValue)
                        .padding(.horizontal, 10)
                }
            }

            ForEach(values.indices, id: \.self) { index in
                ZStack(alignment: .trailing) {
                    FocusableTextField(placeholder, value: Binding(
                        get: { return values[index] },
                        set: { newValue in return self.values[index] = newValue}
                    ),
                    onCommit: {
                        //sanity check to prevent some out of bounds exception
                        if index < values.count && values[index].isEmpty {
                            values.remove(at: index)
                        }
                    })
                    if hovered {
                        DeleteButton(action: {
                            values.remove(at: index)
                        }).padding(.horizontal, 10)
                    }
                }
            }
        }
        .padding()
        .background(hovered ? Color("gray1") : Color.white)
        .cornerRadius(5)
        .onHover { isHovered in
            withAnimation(.easeInOut) {
                self.hovered = isHovered
            }
        }
    }

    private func addTextfieldValue() {
        values.append("")
    }
}

struct InlineTexField_Previews: PreviewProvider {
    static var previews: some View {
        InlineEditableList(title: "A Title", placeholder: "A Placeholder for all my fields", values: .constant(["value1", "value2", ""]))
    }
}

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
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.blue, lineWidth: 1.0, antialiased: true).opacity(isFocused ? 1 : 0))
            .animation(.easeIn)
            .focusable()
    }
}
