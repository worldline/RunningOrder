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

    init(spaceId: Space.ID, createdSprint: Binding<Sprint?>) {
        self.logic = Logic(spaceId: spaceId, createdSprint: createdSprint)
    }

    var body: some View {
        VStack {
            TextField(
                "Sprint Name",
                text: $logic.name,
                onEditingChanged: logic.fieldEditingChanged(valueKeyPath: \.name),
                onCommit: logic.createSprint
            )
            TextField(
                "Sprint Number",
                value: $logic.number,
                formatter: NumberFormatter(),
                onCommit: logic.createSprint
            )

            HStack {
                Button(action: dismiss) { Text("Cancel") }
                Spacer()
                Button(action: logic.createSprint) { Text("Create") }
                    .disabled(!logic.areAllFieldsFilled)
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
        NewSprintView(spaceId: "", createdSprint: .constant(nil))
    }
}
