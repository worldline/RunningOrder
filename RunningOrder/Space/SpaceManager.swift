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
    enum Error: Swift.Error {
        case noSpaceAvailable
    }
}

final class SpaceManager: ObservableObject {
    let spaceService: SpaceService

    var cancellables = Set<AnyCancellable>()

    @Published var availableSpaces: [Space] = []

    @Stored(fileName: "spaces.json", directory: .applicationSupportDirectory) private var storedSpaces: [Space]?

    init(service: SpaceService, dataPublisher: AnyPublisher<ChangeInformation, Never>) {
        self.spaceService = service

        availableSpaces = storedSpaces ?? []

        dataPublisher
            .sink(receiveValue: updateState(with:))
            .store(in: &cancellables)

        $availableSpaces
            .throttle(for: 5, scheduler: DispatchQueue.main, latest: true)
            .map { $0 as [Space]? }
            .assign(to: \.storedSpaces, on: self)
            .store(in: &cancellables)
    }

    private func updateState(with information: ChangeInformation) {
//        Logger.debug.log(information)
        // Si je récupère la suppression du space
        // je resupprime derriere ? (en cas de suppression d'un espace partagé par son possesseur, il faut que je supprime ici aussi)
        deleteData(recordIds: information.toDelete)

        // je récupère les spaces a mettre à jour
        // j'update la liste des spaces actuels (j'ajoute si ils existent pas, ou je remplace les existants)
        updateData(with: information.toUpdate)
    }

    private func updateData(with updatedRecords: [CKRecord]) {
        var currentSpaces = availableSpaces
        for updatedRecord in updatedRecords {
            let updatedSpace = Space(underlyingRecord: updatedRecord)
            if let index = currentSpaces.firstIndex(where: { $0.id == updatedSpace.id }) {
                currentSpaces[index] = updatedSpace
            } else {
                Logger.verbose.log("space with id \(updatedRecord.recordID.recordName) not found, so appending it to existing space list")
                currentSpaces.append(updatedSpace)
            }
        }
        availableSpaces = currentSpaces

//        // If we receive an empty update and we already have no spaces, then we are before creation of space, or subscription to a space.
//        // We need to notify AppStateManager that we received no space in order to display Welcome screen
//        if updatedRecords.isEmpty && availableSpaces.isEmpty {
//            availableSpaces = []
//        }
    }

    private func deleteData(recordIds: [CKRecord.ID]) {
        for recordId in recordIds {
            guard let index = availableSpaces.firstIndex(where: { $0.id == recordId.recordName }) else {
                Logger.warning.log("space not found when deleting \(recordId.recordName)")
                return
            }
            DispatchQueue.main.async {
                self.availableSpaces.remove(at: index)
            }
        }
    }

    private func fetchFromShared(_ recordId: CKRecord.ID) -> AnyPublisher<Space, Swift.Error> {
        Logger.verbose.log("try to fetch from shared")
        let spaceResult = spaceService.fetchShared(recordId)
            .share()
            .print(in: .debug)
            .receive(on: DispatchQueue.main)

        spaceResult
            .catchAndExit({ error in Logger.error.log(error) })
            .filter { !self.availableSpaces.contains($0)}
            .append(to: \.availableSpaces, onStrong: self)
            .store(in: &cancellables)

        return spaceResult.eraseToAnyPublisher()
    }

    func create(space: Space) -> AnyPublisher<Space, Swift.Error> {
        let spaceResult = spaceService.save(space: space)
            .share()
            .receive(on: DispatchQueue.main)

        spaceResult
            .catchAndExit({ _ in })
            .filter { !self.availableSpaces.contains($0)}
            .append(to: \.availableSpaces, onStrong: self)
            .store(in: &cancellables)

        return spaceResult.eraseToAnyPublisher()
    }

    func delete(space: Space) {
        guard let index = self.availableSpaces.firstIndex(where: { $0.id == space.id }) else { return }

        spaceService.delete(space: space)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    Logger.error.log(error)
                case .finished:
                    self.availableSpaces.remove(at: index)
                }
            })
            .store(in: &cancellables)
    }

    func saveAndShare(_ space: Space) -> AnyPublisher<CKShare, Swift.Error> {
        return self.spaceService.saveAndShare(space: space)
    }

    func getShare(_ space: Space) -> AnyPublisher<CKShare, Swift.Error> {
        return self.spaceService.getShare(for: space)
    }

    func acceptShare(metadata: CKShare.Metadata) -> AnyPublisher<Space, Swift.Error> {
        self.spaceService.acceptShare(metadata: metadata)
            .map(\.rootRecordID)
            .flatMap(self.fetchFromShared)
            .eraseToAnyPublisher()
    }
}

extension SpaceManager {
    static let preview = SpaceManager(service: SpaceService(), dataPublisher: Empty().eraseToAnyPublisher())
}
