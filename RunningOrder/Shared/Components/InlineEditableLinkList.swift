//
//  InlineEditableLinkList.swift
//  RunningOrder
//
//  Created by Loic B on 08/04/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI

struct InlineEditableLinkList: View {
    let title: LocalizedStringKey
    @Binding var values: [LinkEntity]

    @State private var hovered = false

    init(title: LocalizedStringKey, values: Binding<[LinkEntity]>) {
        self.title = title
        self._values = values
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.headline)
                    .padding(.leading, 7)

                Spacer()

                if hovered {
                    Button(
                        action: addLinkTextField,
                        label: { Image(systemName: "plus.circle.fill") }
                    )
                    .foregroundColor(.blue)
                    .buttonStyle(InlineButtonStyle())
                }
            }

            ForEach(values) { value in
                InlineEditableLink(
                    value: Binding<LinkEntity>(
                        get: { LinkEntity(label: value.label,
                                          url: value.url)
                        },
                        set: { value in
                            if let index = self.values.firstIndex(of: value) {
                                return self.values[index] = value
                            }
                        }
                    )
                )
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

    private func addLinkTextField() {
        withAnimation {
            values.append(LinkEntity(label: "", url: ""))
        }
    }
}

struct InlineEditableLinkList_Previews: PreviewProvider {
    static var previews: some View {
        InlineEditableLinkList(title: "Add a link", values: .constant([LinkEntity(label: "", url: "")]))
    }
}
