//
//  NewStoryView+Logic.swift
//  RunningOrder
//
//  Created by Clément Nonn on 19/02/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI
import Combine

extension NewStoryView {
    final class Logic: ObservableObject, TextfieldEditingStringHandler {
        let sprintId: Sprint.ID
        @Binding var createdStory: Story?

        @Published var name = ""
        @Published var ticketID = ""
        @Published var epic = ""

        var dismissSubject = PassthroughSubject<Void, Never>()

        var areAllFieldsFilled: Bool {
            return !ticketID.isEmpty && !name.isEmpty && !epic.isEmpty
        }

        init(sprintId: Sprint.ID, createdStory: Binding<Story?>) {
            self.sprintId = sprintId
            self._createdStory = createdStory
        }

        func createStory() {
            guard areAllFieldsFilled else { return }

            // No need of creator reference as it is added by cloudkit.
            // When this record is created, it is sent to cloudkit, that updates it. With the notification subscription, we receive the new record, and update this story with the user reference.
            // TLDR; no need to set the creatorReference ourselves.
            let newStory = Story(
                sprintId: sprintId,
                name: name,
                ticketReference: ticketID,
                epic: epic,
                creatorReference: nil
            )
            self.createdStory = newStory
            dismissSubject.send(())
        }
    }
}
