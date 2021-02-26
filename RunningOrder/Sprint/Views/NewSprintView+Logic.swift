//
//  NewSprintView+Logic.swift
//  RunningOrder
//
//  Created by Clément Nonn on 19/02/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI
import Combine

extension NewSprintView {
    final class Logic: ObservableObject {
        let spaceId: Space.ID
        @Binding var createdSprint: Sprint?

        @Published var name: String = ""
        @Published var number: Int?

        var dismissSubject = PassthroughSubject<Void, Never>()

        var areAllFieldsFilled: Bool { number != nil && !name.isEmpty }

        init(spaceId: Space.ID, createdSprint: Binding<Sprint?>) {
            self.spaceId = spaceId
            self._createdSprint = createdSprint
        }

        func createSprint() {
            guard areAllFieldsFilled else { return }
            self.createdSprint = Sprint(
                spaceId: spaceId,
                number: number!,
                name: name,
                colorIdentifier: Color.Identifier.sprintColors.randomElement()!.rawValue
            )
            dismissSubject.send(())
        }
    }
}
