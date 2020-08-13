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

    func informations(for storyId: Story.ID) -> Binding<StoryInformation> {
        if storyInformations[storyId] == nil {
            let fetched = service.storyInformations.first(where: { $0.storyId == storyId })
            storyInformations[storyId] = fetched ?? StoryInformation(storyId: storyId)
        }

        return Binding {
            self.storyInformations[storyId]!
        } set: { newValue in
            self.storyInformations[storyId] = newValue
        }
    }
}
