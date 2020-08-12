//
//  StoryManager.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 12/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import SwiftUI

final class StoryManager: ObservableObject {
    @Published var stories: [Story] = []

    func fetchStories(sprintId: UUID) {
        stories = Story.Previews.stories.filter {  $0.sprintId == sprintId }
    }

}
