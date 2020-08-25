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

final class StoryInformationService {
    var storyInformations: [StoryInformation] = []
}

final class StoryInformationManager: ObservableObject {

    private let service = StoryInformationService()

    @Published var storyInformations: [Story.ID: StoryInformation] = [:]

    @Published var storyInformationsBuffer: [Story.ID: StoryInformation] = [:]

    var cancellables: Set<AnyCancellable> = []

    private let cloudkitManager = CloudKitManager()

    init() {
        // saving storyinformation while live editing in the list component, each modification is store in the buffer in order to persist it
        // when the saving operation is sent to the cloud, we empty the buffer
        // the throttle is here to reduce the number of operation
        $storyInformationsBuffer
            .filter { !$0.isEmpty }
            .throttle(for: 4.0, scheduler: DispatchQueue.main, latest: true)
            .sink { value in
                self.cloudkitManager.save(storyInformations: Array(value.values))
                    .catchAndExit { error in print(error) } // TODO Error Handling
                    .sink { _ in }
                    .store(in: &self.cancellables)

                self.storyInformationsBuffer = [:]
            }
            .store(in: &cancellables)
    }

    func loadData(for storyId: Story.ID) {
        if storyInformations[storyId] == nil {
            cloudkitManager.fetchStoryInformation(from: storyId)
                .catchAndExit { error in print(error) } // TODO Error Handling
                .receive(on: DispatchQueue.main)
                .replaceEmpty(with: StoryInformation(storyId: storyId))         // we create the storyinformation if it is not yet persisted
                .assign(to: \.storyInformations[storyId], onStrong: self)
                .store(in: &cancellables)
        }
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
