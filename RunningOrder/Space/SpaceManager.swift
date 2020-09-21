//
//  SpaceManager.swift
//  RunningOrder
//
//  Created by Clément Nonn on 22/09/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import Combine
import CloudKit

extension SpaceManager {
    enum State {
        case loading
        case error(Swift.Error)
        case noSpace
        case spaceFound(Space)
    }

    enum Error: Swift.Error {
        case noSpaceAvailable
    }
}

final class SpaceManager: ObservableObject {
    let spaceService: SpaceService

    var cancellables = Set<AnyCancellable>()

    @Published var state: State = .loading

    var space: Space? {
        guard case State.spaceFound(let space) = state else { return nil }

        return space
    }

    init(service: SpaceService) {
        self.spaceService = service
    }

    func initialSetup() {
        // Loading from persistence when set

        spaceService.fetch()
            .map { State.spaceFound($0) }
            .catch { Just(State.error($0)) }
            .replaceEmpty(with: State.noSpace)
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, onStrong: self)
            .store(in: &cancellables)
    }

    func fetchFromShared(_ recordId: CKRecord.ID) {
        Logger.verbose.log("try to fetch from shared")
         spaceService.fetchShared(recordId)
            .map { State.spaceFound($0) }
            .catch { Just(State.error($0)) }
            .replaceEmpty(with: State.error(Error.noSpaceAvailable))
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, onStrong: self)
            .store(in: &cancellables)
    }

    func create(space: Space) -> AnyPublisher<Space, Swift.Error> {
        let spaceResult = spaceService.save(space: space).share().receive(on: DispatchQueue.main)

        spaceResult
            .map { State.spaceFound($0) }
            .catch { Just(State.error($0)) }
            .assign(to: \.state, onStrong: self)
            .store(in: &cancellables)

        return spaceResult.eraseToAnyPublisher()
    }

    func deleteCurrentSpace() {
        if case SpaceManager.State.spaceFound(let space) = self.state {
            spaceService.delete(space: space)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { result in
                    switch result {
                    case .failure(let error):
                        Logger.error.log(error)
                    case .finished:
                        self.state = .noSpace
                    }
                })
                .store(in: &cancellables)
        }
    }

    func saveAndShare() -> AnyPublisher<CKShare, Swift.Error> {
        guard let space = self.space else {
            return Fail(outputType: CKShare.self, failure: Error.noSpaceAvailable).eraseToAnyPublisher()
        }

        return self.spaceService.saveAndShare(space: space)
    }

    func getShare() -> AnyPublisher<CKShare, Swift.Error> {
        guard let space = self.space else {
            return Fail(outputType: CKShare.self, failure: Error.noSpaceAvailable).eraseToAnyPublisher()
        }
        return self.spaceService.getShare(for: space)
    }
}
