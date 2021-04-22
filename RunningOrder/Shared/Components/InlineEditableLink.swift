//
//  InlineEditableLink.swift
//  RunningOrder
//
//  Created by Loic B on 26/02/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI

struct InlineEditableLink: View {
    @State private var hovered = false
    @State private var isEditing: Bool
    @State private var isDoneButtonEnabled = true
    @ObservedObject var logic: Logic

    /// - Parameters:
    ///   - value: A binding to a Link Entity which referers to the Link url and label
    init(value: Binding<Link>) {
        self._isEditing = State(initialValue: value.wrappedValue.label.isEmpty)
        self.logic = Logic(value: value)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if isEditing {
                    VStack {
                        BorderedTextField(placeholder: "Label", value: logic.$value.label)
                        BorderedTextField(placeholder: "Url", value: logic.$value.url)
                    }
                    Spacer()
                    Button(action: {
                        if !logic.isFieldEmpty {
                            self.isEditing = false
                            logic.value.url = logic.formatURL(content: logic.value.url)
                        }
                    }, label: {
                        Text("Done")
                    })
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.accentColor)
                    .disabled(logic.isFieldEmpty)
                } else {
                    HStack {
                        if let url = logic.value.formattedURL {
                            SwiftUI.Link(logic.value.label, destination: url)
                            Spacer()
                            if hovered {
                                Button(action: {
                                    self.isEditing = true
                                }, label: {
                                    Text("Edit")
                                })
                                .buttonStyle(PlainButtonStyle())
                                .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .padding(5)
                }
            }
        }
        .padding(5)
        .background(
            Color(identifier: .snowbank)
                .opacity(hovered ? 1 : 0)
                .cornerRadius(5)
        )
        .onHover { isHovered in
            withAnimation(.easeIn) {
                self.hovered = isHovered
            }
        }
    }
}

struct InlineEditableLink_Previews: PreviewProvider {
    static var previews: some View {
        InlineEditableLink(value: .constant(Link(label: "", url: "")))
        InlineEditableLink(value: .constant(Link(label: "Label", url: "url")))
    }
}
