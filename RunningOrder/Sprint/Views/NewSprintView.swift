//
//  NewSprintView.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct NewSprintView: View {
    @ObservedObject var logic: Logic
    @Environment(\.presentationMode) var presentationMode

    init(space: Space, createdSprint: Binding<Sprint?>) {
        self.logic = Logic(space: space, createdSprint: createdSprint)
    }

    var body: some View {
        VStack {
            TextField(
                "Sprint Name",
                text: $logic.name,
                onEditingChanged: logic.fieldEditingChanged(valueKeyPath: \.name)
            )
            TextField(
                "Sprint Number",
                value: $logic.number,
                formatter: NumberFormatter()
            )

            Picker(selection: $logic.colorIdentifier, label: Text("Sprint Color")) {
                ForEach(Color.Identifier.sprintColors, id: \.self) { sprintColor in
                    Text(sprintColor.rawValue)
                        .foregroundColor(Color(identifier: sprintColor))
                        .tag(sprintColor)
                }
            }
            .labelsHidden()

            Spacer(minLength: 20)

            HStack {
                Button(action: dismiss) { Text("Cancel") }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button(action: logic.createSprint) { Text("Create") }
                    .disabled(!logic.areAllFieldsFilled)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .onReceive(logic.dismissSubject, perform: dismiss)
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct NewSprintView_Previews: PreviewProvider {
    static var previews: some View {
        NewSprintView(space: Space(name: "", zoneId: CKRecordZone.ID()), createdSprint: .constant(nil))
    }
}
