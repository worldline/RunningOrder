//
//  SprintManager.swift
//  RunningOrder
//
//  Created by Clément Nonn on 06/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI
import Combine

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

    func loadData() {
        return service
            .fetchAll()
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: \.sprints, onStrong: self)
            .store(in: &cancellables)

    }
}
