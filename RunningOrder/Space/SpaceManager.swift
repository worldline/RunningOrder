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

    init(service: SpaceService, dataPublisher: AnyPublisher<ChangeInformation, Never>) {
        self.spaceService = service

        dataPublisher
            .map(updateState(with:))
            .assign(to: \.state, onStrong: self)
            .store(in: &cancellables)
    }

    private func updateState(with information: ChangeInformation) -> State {
        Logger.debug.log(information)
        if !information.toDelete.isEmpty, case .spaceFound(let space) = state, information.toDelete.contains(where: { $0.recordName == space.id }) {
            // current space will be deleted
            Logger.warning.log("The current space will be deleted. We should delete the sharing if we are not the 'master'")
        }

        if let record = information.toUpdate.last {
            return .spaceFound(Space(underlyingRecord: record))
        } else {
            return .noSpace
        }
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
        guard case SpaceManager.State.spaceFound(let space) = self.state else { return }

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

    func acceptShare(metadata: CKShare.Metadata) {
        self.spaceService.acceptShare(metadata: metadata)
            .sink(
                receiveFailure: { error in Logger.error.log("error : \(error)") },
                receiveValue: { [weak self] updatedMetadata in self?.fetchFromShared(updatedMetadata.rootRecordID) })
            .store(in: &cancellables)
    }
}
