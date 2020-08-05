//
//  SprintDetailViewModel.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 05/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import Combine

class SprintDetailViewModel: ObservableObject {

    @Published var stories: [Story] = []
    let sprint: Sprint

    init(sprint: Sprint) {
        self.sprint = sprint
    }

    func fetchStories() {
        if let sprintStories = Store.data[sprint] {
            stories = sprintStories
        }
    }

}
