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
                    Logger.error.log(failure) // TODO error Handling
                })
                .store(in: &cancellables)
        }

        func showNewSprintModal() {
            isNewSprintModalPresented = true
        }

        func deleteSprint(_ sprint: Sprint) {
            self.sprintManager.delete(sprint: sprint)
        }
    }
}
