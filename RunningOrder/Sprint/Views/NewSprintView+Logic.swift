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
    final class Logic: ObservableObject, TextfieldEditingStringHandler {
        let space: Space
        @Binding var createdSprint: Sprint?

        @Published var name: String = ""
        @Published var number: Int?
        @Published var colorIdentifier: Color.Identifier = Color.Identifier.sprintColors.randomElement()!

        var dismissSubject = PassthroughSubject<Void, Never>()

        var areAllFieldsFilled: Bool { number != nil && !name.isEmpty }

        init(space: Space, createdSprint: Binding<Sprint?>) {
            self.space = space
            self._createdSprint = createdSprint
        }

        func createSprint() {
            guard areAllFieldsFilled else { return }
            self.createdSprint = Sprint(
                spaceId: space.id,
                number: number!,
                name: name,
                colorIdentifier: colorIdentifier.rawValue,
                closed: false,
                zoneId: space.zoneId
            )
            dismissSubject.send(())
        }
    }
}
