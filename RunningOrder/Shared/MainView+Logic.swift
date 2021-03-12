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

        var createdSpaceBinding: Binding<Space?> { Binding(callback: self.addSpace(_:)) }

        init(spaceManager: SpaceManager) {
            self.spaceManager = spaceManager
        }

        private func addSpace(_ space: Space) {
            spaceManager.create(space: space)
                .ignoreOutput()
                .sink(receiveFailure: { failure in
                    Logger.error.log(failure) // TODO error Handling
                })
                .store(in: &cancellables)
        }
    }
}
