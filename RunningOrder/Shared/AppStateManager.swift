//
//  AppStateManager.swift
//  RunningOrder
//
//  Created by Clément Nonn on 29/03/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

extension AppStateManager {
    enum State {
        case loading
        case error(Swift.Error)
        case spaceCreation
        case spaceSelected(Space)
    }
}

final class AppStateManager: ObservableObject {
    @Published var currentState: State = .loading

    func fetchFirstSpace(in spaceManager: SpaceManager) {
        spaceManager
            .$availableSpaces
            .dropFirst() // avoid the first [] value before changes fetch
            .first() // only the first change to avoid re-updating each time a new space is fetched
//            .timeout(5.0, scheduler: DispatchQueue.main, customError: nil)
            .map { firstSpaces in
                if let foundSpace = firstSpaces.last {
                    return .spaceSelected(foundSpace)
                } else {
                    return .spaceCreation
                }
            }
            .assign(to: &$currentState)
    }
}
