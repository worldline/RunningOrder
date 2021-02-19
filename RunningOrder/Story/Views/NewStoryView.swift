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

    init(sprintId: Sprint.ID, createdStory: Binding<Story?>) {
        self.logic = Logic(sprintId: sprintId, createdStory: createdStory)
    }

    var body: some View {
        VStack {
            TextField("Story Name", text: $logic.name)
            TextField("Ticket ID", text: $logic.ticketID)
            TextField("Story EPIC", text: $logic.epic, onCommit: logic.createStory)

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
        NewStoryView(sprintId: Sprint.Previews.sprints[0].id, createdStory: .constant(nil))
    }
}
