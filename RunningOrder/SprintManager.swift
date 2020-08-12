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
    @Published var sprints: [Sprint] = Sprint.Previews.sprints
}
