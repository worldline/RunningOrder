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

    @Binding var createdSprint: Sprint?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            TextField("Sprint Name", text: $name, onEditingChanged: { _ in }, onCommit: createSprint)

            HStack {
                Button(action: dismiss) { Text("Cancel") }
                Spacer()
                Button(action: createSprint) { Text("Create") }
            }
        }.padding()
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    private func createSprint() {
        let sprint = Sprint(name: name, stories: [])
        self.createdSprint = sprint
        presentationMode.wrappedValue.dismiss()
    }
}

struct NewSprintView_Previews: PreviewProvider {
    static var previews: some View {
        NewSprintView(createdSprint: .constant(nil))
    }
}
