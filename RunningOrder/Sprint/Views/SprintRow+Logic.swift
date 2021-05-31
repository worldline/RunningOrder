//
//  SprintRow+Logic.swift
//  RunningOrder
//
//  Created by Clément Nonn on 31/05/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

extension SprintRow {
    final class Logic: ObservableObject {
        private unowned var sprintManager: SprintManager
        private var sprintToDeleteBinding: Binding<Sprint?>

        init(sprintManager: SprintManager, sprintToDeleteBinding: Binding<Sprint?>) {
            self.sprintManager = sprintManager
            self.sprintToDeleteBinding = sprintToDeleteBinding
        }

        func deleteSprint(_ sprint: Sprint) {
            sprintToDeleteBinding.wrappedValue = sprint
        }

        func closeSprint(_ sprint: Sprint) {
            var closedSprint = sprint
            closedSprint.closed = true
            sprintManager.updateSprint(sprint: closedSprint)
        }

        func reopenSprint(_ sprint: Sprint) {
            var reopenedSprint = sprint
            reopenedSprint.closed = false
            sprintManager.updateSprint(sprint: reopenedSprint)
        }
    }
}
