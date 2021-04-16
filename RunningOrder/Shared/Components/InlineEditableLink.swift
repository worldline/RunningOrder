//
//  InlineEditableLink.swift
//  RunningOrder
//
//  Created by Loic B on 26/02/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI

struct InlineEditableLink: View {
    @Binding var value: LinkEntity
    @State private var hovered = false
    @State private var isEditing: Bool
    @State private var isDoneButtonEnabled = true

    /// - Parameters:
    ///   - value: A binding to a Link Entity which referers to the Link url and label
    init(value: Binding<LinkEntity>) {
        self._value = value
        self._isEditing = State(initialValue: value.wrappedValue.label.isEmpty)
    }

    var isFieldsEmpty: Bool {
        return value.url.isEmpty || value.label.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if isEditing {
                    VStack {
                        StyledFocusableTextField("Label",
                                                 value: $value.label,
                                                 onCommit: {})
                        StyledFocusableTextField("Url",
                                                 value: $value.url,
                                                 onCommit: {})
                    }
                    Spacer()
                    Button(action: {
                        if !isFieldsEmpty {
                            self.isEditing = false
                            value.url = formatURL(content: value.url)
                        }
                    }, label: {
                        Text("Done")
                    })
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.accentColor)
                    .disabled(isFieldsEmpty)
                } else {
                    if let url = value.formattedURL {
                        Link(value.label,
                             destination: url)
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

    private func formatURL(content: String) -> String {
        var url = content
        if !value.url.contains("https://") && !value.url.contains("http://") {
            url.insert(contentsOf: "https://", at: value.url.startIndex)
        }
        return url
    }
}

struct InlineEditableLink_Previews: PreviewProvider {
    static var previews: some View {
        InlineEditableLink(value: .constant(LinkEntity(label: "", url: "")))
        InlineEditableLink(value: .constant(LinkEntity(label: "Label", url: "url")))
    }
}
