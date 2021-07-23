//
//  MainView+Logic.swift
//  RunningOrder
//
//  Created by Clément Nonn on 19/02/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI
import Combine

extension MainView {
    final class Logic: ObservableObject {
        private var cancellables = Set<AnyCancellable>()
        private unowned var spaceManager: SpaceManager
        private unowned var appStateManager: AppStateManager

        var createdSpaceBinding: Binding<Space?> {
            Binding(callback: { newSpace in
                self.addSpace(newSpace)
                self.appStateManager.currentState = .spaceSelected(newSpace)
            })
        }

        init(spaceManager: SpaceManager, appStateManager: AppStateManager) {
            self.spaceManager = spaceManager
            self.appStateManager = appStateManager
        }

        private func addSpace(_ space: Space) {
            spaceManager.create(space: space)
                .ignoreOutput()
                .sink(receiveFailure: { failure in
                    NotificationCenter.default.postError(failure)
                })
                .store(in: &cancellables)
        }
    }
}
