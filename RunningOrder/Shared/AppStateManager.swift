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
        case idle
        case loading(Progress)
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
    @Published var currentState: State = .idle

    @AppStorage("currentSpaceName") private var storedSpaceName: String?

    private unowned var changesService: CloudKitChangesService

    private var spaceNameCancellable: AnyCancellable?

    @Published var currentLoading: Progress?

    init(changesService: CloudKitChangesService) {
        self.changesService = changesService
        Timer
            .publish(every: 180, on: .main, in: .default)
            .autoconnect()
            .map { _ in
                changesService.refreshAll()
            }
            .assign(to: &$currentLoading)

        $currentLoading
            .unwrap()
            .flatMap { progress in
                progress.publisher(for: \.isFinished)
            }
            .filter { $0 }
            .map { _ -> Progress? in
                return nil
            }
            .delay(for: 1, scheduler: DispatchQueue.main)
            .assign(to: &$currentLoading)

        spaceNameCancellable = $currentState
            .compactMap {
                if case .spaceSelected(let space) = $0 {
                    return space.name
                } else {
                    return nil
                }
            }
            .assign(to: \.storedSpaceName, onStrong: self)
    }

    func refreshAll() {
        currentLoading = changesService.refreshAll(qos: .userInitiated)
    }

    func fetchFirstSpace(in spaceManager: SpaceManager, withProgress progress: Progress) {
        self.currentState = .loading(progress)

        let progressEndedPublisher: AnyPublisher<Bool, Never>

        if progress.isIndeterminate {
            progressEndedPublisher = Just(true)
                .eraseToAnyPublisher()
        } else {
            progressEndedPublisher = progress
                .publisher(for: \.isFinished)
                .filter { $0 }
                .first()
                .delay(for: 0.5, scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        }

        spaceManager
            .$availableSpaces
            .combineLatest(progressEndedPublisher)
            .map(\.0)
            .first(where: { // only the first change to avoid re-updating each time a new space is fetched, but we still wait if the stored space is not in the first stored spaces fetched
                if let storedSpaceName = self.storedSpaceName {
                    return $0.contains(where: { space in space.name == storedSpaceName })
                } else {
                    return true
                }
            })
            .map { firstSpaces in
                if let storedSpaceName = self.storedSpaceName,
                   let foundSpace = firstSpaces.first(where: { $0.name == storedSpaceName }) {
                    return .spaceSelected(foundSpace)
                } else if let foundSpace = firstSpaces.last {
                    return .spaceSelected(foundSpace)
                } else {
                    return .spaceCreation
                }
            }
            .assign(to: &$currentState)
    }
}

extension AppStateManager {
    static let preview = AppStateManager(changesService: CloudKitChangesService(container: CloudKitContainer.shared))
}
