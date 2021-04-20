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

extension AppStateManager {
    enum Error: Swift.Error {
        case unexistingError // in the mapError I need a concrete error to return, but I don't want to use an existing one in order to identify a potential bug if this error is really thrown
        case fetchTimeout
    }
}

final class AppStateManager: ObservableObject {
    @Published var currentState: State = .loading

    @AppStorage("currentSpaceName") private var storedSpaceName: String?

    private var isFirstCall = true

    private var spaceNameCancellable: AnyCancellable?

    init() {
        spaceNameCancellable = $currentState
            .compactMap {
                if case .spaceSelected(let space) = $0 {
                    return space.name
                } else {
                    return nil
                }
            }
            .print(in: Logger.debug)
            .assign(to: \.storedSpaceName, onStrong: self)
    }

    func fetchFirstSpace(in spaceManager: SpaceManager) {
        let isFirstCall = self.isFirstCall
        self.isFirstCall = false
        spaceManager
            .$availableSpaces
            .dropFirst(isFirstCall ? 1 : 0) // avoid the [] value before first changes fetch. next time won't need it
            .first(where: { // only the first change to avoid re-updating each time a new space is fetched, but we still wait if the stored space is not in the first stored spaces fetched
                if let storedSpaceName = self.storedSpaceName {
                    return $0.contains(where: { space in space.name == storedSpaceName })
                } else {
                    return true
                }
            })
            .mapError { _ -> Error in Error.unexistingError } // Map never to an error type to allow to use timeout
            .timeout(5.0, scheduler: DispatchQueue.main, customError: { Error.fetchTimeout }) // timeout if too long
            .map { firstSpaces in
                Logger.debug.log(firstSpaces)
                if let storedSpaceName = self.storedSpaceName,
                   let foundSpace = firstSpaces.first(where: { $0.name == storedSpaceName }) {
                    return .spaceSelected(foundSpace)
                } else if let foundSpace = firstSpaces.last {
                    return .spaceSelected(foundSpace)
                } else {
                    return .spaceCreation
                }
            }
            .catch { error in Just(AppStateManager.State.error(error)) } // catch timeout error
            .assign(to: &$currentState)
    }
}
