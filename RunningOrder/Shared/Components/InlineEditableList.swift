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
struct InlineEditableList: View {

    let title: LocalizedStringKey

    let placeholder: String

    @Binding var values: [String]
    @State private var hovered = false

    /// - Parameters:
    ///   - title: The title to describe the editable list
    ///   - placeholder: The placeholder to put in every list items
    ///   - values: A binding to a string array which referers to the list values
    init(title: LocalizedStringKey, placeholder: String = "", values: Binding<[String]>) {
        self.title = title
        self._values = values
        self.placeholder = placeholder
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .foregroundColor(.gray)
                    .padding(.all, 6)
                Spacer()
                if hovered {
                    RoundButton(image: Image(nsImageName: NSImage.addTemplateName),
                                color: Color.blue,
                                action: addTextfieldValue)
                        .frame(width: 17, height: 17)
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
                        // we delete the field if its value is empty
                        if values[index].isEmpty {
                            deleteTextfieldValue(at: index)
                        }
                    })
                    if hovered {
                        RoundButton(image: Image(nsImageName: NSImage.removeTemplateName),
                                    color: Color.red,
                                    action: { deleteTextfieldValue(at: index) })
                            .frame(width: 17, height: 17)
                            .padding(.horizontal, 10)
                    }
                }
            }
        }
        .padding(.all, 5)
        .background(Color(identifier: .snowbank).opacity(hovered ? 1 : 0))
        .cornerRadius(5)
        .onHover { isHovered in
            withAnimation(.easeIn) {
                self.hovered = isHovered
            }
        }
    }

    private func addTextfieldValue() {
        withAnimation {
            values.append("")
        }
    }

    private func deleteTextfieldValue(at index: Int) {
        //sanity check to prevent some out of bounds exception
        guard index < values.count else { return }

        withAnimation {
            _ = values.remove(at: index)
        }
    }
}

struct InlineTexField_Previews: PreviewProvider {
    static var previews: some View {
        InlineEditableList(title: "A Title", placeholder: "A Placeholder for all my fields", values: .constant(["value1", "value2", ""]))
    }
}
