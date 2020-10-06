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

///The class responsible of managing the Sprint data, this is the only source of truth
final class SprintManager: ObservableObject {
    @Published var sprints: [Sprint] = []

    var cancellables: Set<AnyCancellable> = []

    private let service: SprintService

    init(service: SprintService) {
        self.service = service
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

    func updateData(with updatedRecords: [CKRecord]) {
        for updatedRecord in updatedRecords {
            do {
                let sprint = try Sprint(from: updatedRecord)
                if let index = sprints.firstIndex(where: { $0.id == sprint.id }) {
                    sprints[index] = sprint
                } else {
                    Logger.warning.log("sprint with id \(sprint.id) not found, so appending it to existing sprint list")
                    sprints.append(sprint)
                }
            } catch {
                Logger.error.log(error)
            }
        }
    }

    func deleteData(recordIds: [CKRecord.ID]) {
        for recordId in recordIds {
            guard let index = sprints.firstIndex(where: { $0.id == recordId.recordName }) else {
                Logger.warning.log("sprint not found when deleting \(recordId.recordName)")
                return
            }
            sprints.remove(at: index)
        }
    }
}
