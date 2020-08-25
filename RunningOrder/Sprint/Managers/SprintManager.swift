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

    private let cloudkitManager = CloudKitManager()

    func add(sprint: Sprint) -> AnyPublisher<[Sprint], Error> {

        let saveSprintPublisher = cloudkitManager.save(sprint: sprint)
            .map { (savedSprint: Sprint) -> [Sprint] in
                var newSprints = self.sprints
                newSprints.append(savedSprint)
                return newSprints
            }
            .share()
            .receive(on: DispatchQueue.main)

        saveSprintPublisher
            .catchAndExit { _ in }
            .assign(to: \.sprints, onStrong: self)
            .store(in: &cancellables)

        return saveSprintPublisher.eraseToAnyPublisher()
    }

    func loadData() {
        return cloudkitManager
            .fetchAllSprints()
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .assign(to: \.sprints, onStrong: self)
            .store(in: &cancellables)

    }
}
