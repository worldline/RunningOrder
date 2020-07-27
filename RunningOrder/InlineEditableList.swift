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
                RoundButton(imageName: NSImage.addTemplateName, color: Color.blue, action: addTextfieldValue)
                    .frame(width: 20, height: 20)
                    .padding(.horizontal, 10)
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
                        RoundButton(imageName: NSImage.removeTemplateName, color: Color.red, action: {
                            values.remove(at: index)
                        })
                        .frame(width: 20, height: 20)
                        .padding(.horizontal, 10)
                }
            }
        }
        .padding()
        .background(hovered ? Color("gray1") : Color.clear)
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
