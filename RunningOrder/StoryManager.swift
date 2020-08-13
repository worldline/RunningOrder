//
//  StoryManager.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 12/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

final class StoryManager: ObservableObject {
    @Published var stories: [Story] = []

    func fetchStories(sprintId: Sprint.ID) {
        if let sprintStories = Storage.stories[sprintId] {
            stories = sprintStories
        }
    }

}
