//
//  NewStory`View.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 27/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct NewStoryView: View {
    @ObservedObject var logic: Logic
    @Environment(\.presentationMode) var presentationMode

    init(sprint: Sprint, createdStory: Binding<Story?>) {
        self.logic = Logic(sprint: sprint, createdStory: createdStory)
    }

    var body: some View {
        VStack {
            TextField(
                "Story Name",
                text: $logic.name,
                onEditingChanged: logic.fieldEditingChanged(valueKeyPath: \.name)
            )
            TextField(
                "Ticket ID",
                text: $logic.ticketID,
                onEditingChanged: logic.fieldEditingChanged(valueKeyPath: \.ticketID)
            )
            TextField(
                "Story EPIC",
                text: $logic.epic,
                onEditingChanged: logic.fieldEditingChanged(valueKeyPath: \.epic),
                onCommit: logic.createStory
            )

            HStack {
                Button(action: dismiss) { Text("Cancel") }
                Spacer()
                Button(action: logic.createStory) { Text("Create") }
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

struct NewStoryView_Previews: PreviewProvider {
    static var previews: some View {
        NewStoryView(sprint: Sprint.Previews.sprints[0], createdStory: .constant(nil))
    }
}
