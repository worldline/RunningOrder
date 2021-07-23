//
//  SprintList+Logic.swift
//  RunningOrder
//
//  Created by Clément Nonn on 19/02/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

extension SprintList {
    final class Logic: ObservableObject {
        private var cancellables = Set<AnyCancellable>()
        private unowned var sprintManager: SprintManager

        @Published var isNewSprintModalPresented = false

        var createdSprintBinding: Binding<Sprint?> { Binding(callback: self.addSprint(_:)) }

        init(sprintManager: SprintManager) {
            self.sprintManager = sprintManager
        }

        private func addSprint(_ sprint: Sprint) {
            sprintManager.add(sprint: sprint)
                .ignoreOutput()
                .sink(receiveFailure: { failure in
                    NotificationCenter.default.postError(failure)
                })
                .store(in: &cancellables)
        }

        func showNewSprintModal() {
            isNewSprintModalPresented = true
        }

        func activeSprints(for spaceId: Space.ID) -> [Sprint] {
            sprintManager.sprints(for: spaceId).filter { !$0.closed }
        }

        func closedSprints(for spaceId: Space.ID) -> [Sprint] {
            sprintManager.sprints(for: spaceId).filter { $0.closed }
        }

        func deleteSprint(_ sprint: Sprint) {
            sprintManager.delete(sprint: sprint)
        }
    }
}
