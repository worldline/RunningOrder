//
//  NewSprintView.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct NewSprintView: View {
    let spaceId: String
    @State private var name: String = ""
    @State private var number: Int?

    private var areAllFieldsFilled: Bool {
        return number != nil && !name.isEmpty
    }

    @Binding var createdSprint: Sprint?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            TextField("Sprint Name", text: $name, onEditingChanged: { _ in }, onCommit: createSprint)
            TextField("Sprint Number", value: $number, formatter: NumberFormatter(), onCommit: createSprint)

            HStack {
                Button(action: dismiss) { Text("Cancel") }
                Spacer()
                Button(action: createSprint) { Text("Create") }
                    .disabled(!areAllFieldsFilled)
            }
        }.padding()
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    private func createSprint() {
        guard areAllFieldsFilled else { return }
        self.createdSprint = Sprint(
            spaceId: spaceId,
            number: number!,
            name: name,
            colorIdentifier: Color.Identifier.sprintColors.randomElement()!.rawValue
        )
        dismiss()
    }
}

struct NewSprintView_Previews: PreviewProvider {
    static var previews: some View {
        NewSprintView(spaceId: "", createdSprint: .constant(nil))
    }
}
