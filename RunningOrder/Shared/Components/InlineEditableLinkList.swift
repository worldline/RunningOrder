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

    @State private var hovered = false
    @ObservedObject var logic: Logic

    init(title: LocalizedStringKey, values: Binding<[Link]>) {
        self.title = title
        self.logic = Logic(values: values)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.title2)
                    .padding(.leading, 7)

                Spacer()

                Button(
                    action: logic.addLinkTextField,
                    label: { Image(systemName: "plus.circle.fill") }
                )
                .foregroundColor(.blue)
                .buttonStyle(InlineButtonStyle())
            }
            .padding(.bottom, 10)

            ForEach(logic.values.indices, id: \.self) { index in
                HStack {
                    InlineEditableLink(value: self.logic.linkBinding(for: index))
                    Button(
                        action: { logic.deleteTextField(at: index) },
                        label: { Image(systemName: "minus.circle.fill") }
                    )
                    .foregroundColor(.red)
                    .buttonStyle(InlineButtonStyle())
                }
            }
        }
        .padding(5)
        .background(
            Color(identifier: .snowbank)
                .opacity(hovered ? 1 : 0)
                .cornerRadius(5)
        )
    }
}

struct InlineEditableLinkList_Previews: PreviewProvider {
    static var previews: some View {
        InlineEditableLinkList(title: "Add a link", values: .constant([Link(label: "", url: "")]))
    }
}
