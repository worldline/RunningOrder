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

    func mutableSprint(_ sprint: Sprint) -> Binding<Sprint> {
        guard let index = sprints.firstIndex(of: sprint) else { fatalError() }
        return Binding {
            self.sprints[index]
        } set: { newValue in
            self.sprints[index] = newValue
        }
    }
}
