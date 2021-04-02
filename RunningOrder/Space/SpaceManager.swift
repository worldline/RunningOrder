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

    init(service: SpaceService, dataPublisher: AnyPublisher<ChangeInformation, Never>) {
        self.spaceService = service

        dataPublisher
            .sink(receiveValue: updateState(with:))
            .store(in: &cancellables)
    }

    private func updateState(with information: ChangeInformation) {
        Logger.debug.log(information)
        // Si je récupère la suppression du space
        // je resupprime derriere ? (en cas de suppression d'un espace partagé par son possesseur, il faut que je supprime ici aussi)
        deleteData(recordIds: information.toDelete)

        // je récupère les spaces a mettre à jour
        // j'update la liste des spaces actuels (j'ajoute si ils existent pas, ou je remplace les existants)
        updateData(with: information.toUpdate)
    }

    private func updateData(with updatedRecords: [CKRecord]) {
        for updatedRecord in updatedRecords {
            let updatedSpace = Space(underlyingRecord: updatedRecord)
            if let index = availableSpaces.firstIndex(where: { $0.id == updatedSpace.id }) {
                DispatchQueue.main.async {
                    self.availableSpaces[index] = updatedSpace
                }
            } else {
                Logger.verbose.log("space with id \(updatedRecord.recordID.recordName) not found, so appending it to existing space list")
                DispatchQueue.main.async {
                    self.availableSpaces.append(updatedSpace)
                }
            }
        }
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

    private func fetchFromShared(_ recordId: CKRecord.ID) {
        Logger.verbose.log("try to fetch from shared")
        spaceService.fetchShared(recordId)
            .catchAndExit { error in Logger.error.log(error) }
            .append(to: \.availableSpaces, onStrong: self)
            .store(in: &cancellables)
    }

    func create(space: Space) -> AnyPublisher<Space, Swift.Error> {
        let spaceResult = spaceService.save(space: space)
            .share()
            .receive(on: DispatchQueue.main)

        // TODO: check id of created space before adding it
        spaceResult
            .catchAndExit({ _ in })
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

    func acceptShare(metadata: CKShare.Metadata) {
        self.spaceService.acceptShare(metadata: metadata)
            .sink(
                receiveFailure: { error in Logger.error.log("error : \(error)") },
                receiveValue: { [weak self] updatedMetadata in self?.fetchFromShared(updatedMetadata.rootRecordID)
                }
            )
            .store(in: &cancellables)
    }
}

extension SpaceManager {
    static let preview = SpaceManager(service: SpaceService(), dataPublisher: Empty().eraseToAnyPublisher())
}
