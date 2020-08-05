//
//  SprintListViewModel.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 05/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import Combine

class SprintListViewModel: ObservableObject {
    @Published var selection: Sprint?
    @Published var sprints: [Sprint] = []

    func fetchSprints() {
        sprints = [Sprint](Store.data.keys)
    }
}
