//
//  StoryInformationManager.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 12/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

final class StoryInformationManager: ObservableObject {

    @Published var storyInformations: [Story.ID: StoryInformation] = [:]

    @Published var storyInformationsBuffer: [Story.ID: StoryInformation] = [:]

    var cancellables: Set<AnyCancellable> = []

    private let service: StoryInformationService

    init(service: StoryInformationService) {
        self.service = service

        // saving storyinformation while live editing in the list component, each modification is stored in the buffer in order to persist it
        // when the saving operation is sent to the cloud, we empty the buffer
        // the throttle is here to reduce the number of operation
        $storyInformationsBuffer
            .filter { !$0.isEmpty }
            .throttle(for: 4.0, scheduler: DispatchQueue.main, latest: true)
            .sink { value in
                self.service.save(storyInformations: Array(value.values))
                    .ignoreOutput()
                    .sink (receiveFailure: { failure in
                        print(failure) // TODO error Handling
                    })
                    .store(in: &self.cancellables)

                self.storyInformationsBuffer.removeAll()
            }
            .store(in: &cancellables)
    }

    func loadData(for storyId: Story.ID) {
        guard storyInformations[storyId] == nil else { return } // we only need to fetch the information once

        service.fetch(from: storyId)
            .catchAndExit { error in print(error) } // TODO Error Handling
            .receive(on: DispatchQueue.main)
            .replaceEmpty(with: StoryInformation(storyId: storyId))         // we create the storyinformation if it is not yet persisted
            .assign(to: \.storyInformations[storyId], onStrong: self)
            .store(in: &cancellables)
    }

    func informations(for storyId: Story.ID) -> Binding<StoryInformation> {
        return Binding {
            self.storyInformations[storyId]!
        } set: { newValue in
            self.storyInformations[storyId] = newValue
            self.storyInformationsBuffer[storyId] = newValue
        }
    }
}
