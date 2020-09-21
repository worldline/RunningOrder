//
//  NewStory`View.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 27/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct NewStoryView: View {

    let sprintId: Sprint.ID

    @State private var name = ""
    @State private var ticketID = ""
    @State private var epic = ""

    private var areAllFieldsFilled: Bool {
        return !ticketID.isEmpty && !name.isEmpty && !epic.isEmpty
    }

    @Binding var createdStory: Story?

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            TextField("Story Name", text: $name)
            TextField("Ticket ID", text: $ticketID)
            TextField("Story EPIC", text: $epic, onEditingChanged: { _ in }, onCommit: createStory )

            HStack {
                Button(action: dismiss) { Text("Cancel") }
                Spacer()
                Button(action: createStory) { Text("Create") }
                    .disabled(!areAllFieldsFilled)
            }
        }.padding()
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    private func createStory() {
        guard areAllFieldsFilled else { return }

        let newStory = Story(sprintId: sprintId, name: name, ticketReference: ticketID, epic: epic)
        self.createdStory = newStory
        dismiss()
    }
}

#if DEBUG
struct NewStoryView_Previews: PreviewProvider {
    static var previews: some View {
        NewStoryView(sprintId: Sprint.Previews.sprints[0].id, createdStory: .constant(nil))
    }
}
#endif
