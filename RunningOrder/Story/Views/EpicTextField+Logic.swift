//
//  EpicTextField+Logic.swift
//  RunningOrder
//
//  Created by Clément Nonn on 15/07/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI

extension EpicTextField {
    final class Logic: ObservableObject {
        @Binding var epic: String

        let spaceId: Space.ID

        var isFocused: Binding<Bool>
        var showEpicSuggestions: Binding<Bool> {
            Binding {
                return self.isFocused.wrappedValue && !self.epic.isEmpty && !self.epicList.isEmpty
            } set: { _ in }
        }

        private unowned var storyManager: StoryManager
        private unowned var sprintManager: SprintManager

        init(epic: Binding<String>, spaceId: Space.ID, isFocused: Binding<Bool>, storyManager: StoryManager, sprintManager: SprintManager) {
            self._epic = epic
            self.spaceId = spaceId
            self.isFocused = isFocused
            self.storyManager = storyManager
            self.sprintManager = sprintManager
        }

        var epicList: [String] {
            let sprintIds = sprintManager.sprints(for: spaceId).map { $0.id }
            return storyManager.epics(for: sprintIds)
                .filter { $0.contains(epic, options: .caseInsensitive) }
        }

        func selectEpic(_ epic: String) {
            self.epic = epic
            isFocused.wrappedValue = false
        }
    }
}
