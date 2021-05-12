//
//  SprintManager.swift
//  RunningOrder
//
//  Created by Clément Nonn on 06/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI
import Combine
import CloudKit

/// The class responsible of managing the Sprint data, this is the only source of truth
final class SprintManager: ObservableObject {
    @Published var sprints: [Sprint] = []

    var cancellables: Set<AnyCancellable> = []

    private let service: SprintService

    init(service: SprintService, dataPublisher: AnyPublisher<ChangeInformation, Never>) {
        self.service = service

        dataPublisher.sink(receiveValue: { [weak self] informations in
            self?.updateData(with: informations.toUpdate)
            self?.deleteData(recordIds: informations.toDelete)
        }).store(in: &cancellables)
    }

    func add(sprint: Sprint) -> AnyPublisher<Sprint, Error> {
        let saveSprintPublisher = service.save(sprint: sprint)
            .share()
            .receive(on: DispatchQueue.main)

        saveSprintPublisher
            .catchAndExit { _ in }
            .append(to: \.sprints, onStrong: self)
            .store(in: &cancellables)

        return saveSprintPublisher.eraseToAnyPublisher()
    }

    /// Returns the sprints of a specific spaceId
    /// - Parameter spaceId: The id of the space
    func sprints(for spaceId: Space.ID) -> [Sprint] {
        return sprints.filter { $0.spaceId == spaceId}
    }

    func updateData(with updatedRecords: [CKRecord]) {
        for updatedRecord in updatedRecords {
            do {
                let sprint = try Sprint(from: updatedRecord)
                if let index = sprints.firstIndex(where: { $0.id == sprint.id }) {
                    DispatchQueue.main.async {
                        self.sprints[index] = sprint
                    }
                } else {
                    Logger.verbose.log("sprint with id \(sprint.id) not found, so appending it to existing sprint list")
                    DispatchQueue.main.async {
                        self.sprints.append(sprint)
                    }
                }
            } catch {
                Logger.error.log(error)
            }
        }
    }

    func delete(sprint: Sprint) {
        guard let index = self.sprints.firstIndex(of: sprint) else {
            Logger.error.log("couldn't find index of sprint in stored sprints")
            return
        }

        service.delete(sprint: sprint)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    Logger.error.log(error) // TODO: error Handling
                case .finished:
                    self?.sprints.remove(at: index)
                }
            })
            .store(in: &cancellables)
    }

    func deleteData(recordIds: [CKRecord.ID]) {
        for recordId in recordIds {
            guard let index = sprints.firstIndex(where: { $0.id == recordId.recordName }) else {
                Logger.warning.log("sprint not found when deleting \(recordId.recordName)")
                return
            }
            DispatchQueue.main.async {
                self.sprints.remove(at: index)
            }
        }
    }

    func closeSprint(sprint: Sprint) {
        guard let index = self.sprints.firstIndex(of: sprint) else {
            Logger.error.log("couldn't find index of sprint in stored sprints")
            return
        }

        self.sprints[index].closed = true
        service.save(sprint: self.sprints[index])
            .print(in: Logger.debug)
            .ignoreOutput()
            .sink(receiveFailure: { error in
                Logger.error.log(error)
            })
            .store(in: &cancellables)
    }
}

extension SprintManager {
    static let preview = SprintManager(service: SprintService(), dataPublisher: Empty().eraseToAnyPublisher())
}
