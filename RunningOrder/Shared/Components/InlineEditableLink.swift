//
//  InlineEditableLink.swift
//  RunningOrder
//
//  Created by Loic B on 26/02/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI

struct InlineEditableLink: View {
    let placeholder: String

    @Binding var values: LinkEntity
    @State private var hovered = false
    @State private var isEditing = false
    @State private var isDoneButtonEnabled = true

    /// - Parameters:
    ///   - placeholder: The placeholder to put in every items
    ///   - values: A binding to a Link Entity which referers to the Link url and label
    init(placeholder: String = "", values: Binding<LinkEntity>) {
        self._values = values
        self.placeholder = placeholder
    }

    var isFieldsEmpty: Bool {
        return values.url.isEmpty || values.label.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if isEditing {
                    VStack {
                        StyledFocusableTextField(placeholder,
                                                 value: $values.label,
                                                 onCommit: {
//                                                    if values.url.isEmpty && values.label.isEmpty {
//                                                        self.isDoneButtonEnabled = false
//                                                    }
                                                 })
                        StyledFocusableTextField(placeholder,
                                                 value: $values.url,
                                                 onCommit: {})
                    }
                    Spacer()
                    Button(action: {
                        if !isFieldsEmpty {
                            self.isEditing = false
                            values.url = formatURL(content: values.url)
                        }
                    }, label: {
                        Text("Done")
                    })
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.accentColor)
                    .disabled(isFieldsEmpty)
                } else {
                    if let url = values.formattedURL {
                        Link(values.label,
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
        if !values.url.contains("https://") && !values.url.contains("http://") {
            url.insert(contentsOf: "https://", at: values.url.startIndex)
        }
        return url
    }
}

struct InlineEditableLinkList_Previews: PreviewProvider {
    static var previews: some View {
        InlineEditableLink(values: .constant(LinkEntity(label: "", url: "")))
    }
}
