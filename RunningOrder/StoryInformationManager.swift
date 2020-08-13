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

    @Published var storyInformation = StoryInformation(storyId: "")

    private var cancellable: AnyCancellable?

    init() {
        cancellable = $storyInformation
            .dropFirst()
            .sink { _ in
                self.saveInformation()
            }
    }

    func fetchInformation(storyId: Story.ID) {
        if let storyInformation = Storage.informations[storyId] {
            self.storyInformation = storyInformation
        }
    }

    func saveInformation() {
        Storage.informations[storyInformation.storyId] = storyInformation
    }

}
