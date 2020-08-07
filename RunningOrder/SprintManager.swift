//
//  SprintManager.swift
//  RunningOrder
//
//  Created by Clément Nonn on 06/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Combine
import SwiftUI

final class SprintManager: ObservableObject {
    @Published var sprints: [Sprint] = []

    func mutableSprint(sprintIndex: Int) -> Binding<Sprint> {
        guard sprintIndex < sprints.count else { fatalError() } // TODO Error handling
        return Binding {
            self.sprints[sprintIndex]
        } set: { newValue in
            self.sprints[sprintIndex] = newValue
        }
    }

    func mutableStory(sprintIndex: Int, storyIndex: Int) -> Binding<Story> {
        guard sprintIndex < sprints.count else { fatalError() } // TODO Error handling
        guard storyIndex < sprints[sprintIndex].stories.count else { fatalError() }

        return Binding {
            self.sprints[sprintIndex].stories[storyIndex]
        } set: { newValue in
            self.sprints[sprintIndex].stories[storyIndex] = newValue

        }
    }
}
