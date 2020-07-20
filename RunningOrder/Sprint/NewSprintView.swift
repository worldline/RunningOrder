//
//  NewSprintView.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct NewSprintView: View {
    @State private var name: String = ""
    @State private var number: Int?

    @Binding var createdSprint: Sprint?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            TextField("Sprint Number", value: $number, formatter: NumberFormatter())
            TextField("Sprint Name", text: $name, onEditingChanged: { _ in }, onCommit: createSprint)

            HStack {
                Button(action: dismiss) { Text("Cancel") }
                Spacer()
                Button(action: createSprint) { Text("Create") }
                    .disabled(number == nil || name == "")
            }
        }.padding()
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    private func createSprint() {
        if number != nil && name != "" {
            let sprint = Sprint(number: number!, name: name, color: .init(0x2FBAD5), stories: [])
            self.createdSprint = sprint
            dismiss()
        }
    }
}

struct NewSprintView_Previews: PreviewProvider {
    static var previews: some View {
        NewSprintView(createdSprint: .constant(nil))
    }
}
