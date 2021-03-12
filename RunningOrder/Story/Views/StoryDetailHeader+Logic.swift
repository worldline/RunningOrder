//
//  StoryDetailHeader+Logic.swift
//  RunningOrder
//
//  Created by Clément Nonn on 12/03/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation
import Combine

extension StoryDetailHeader {
    final class Logic: ObservableObject {
        @Published var userName: String?

        private unowned var storyManager: StoryManager

        init(storyManager: StoryManager) {
            self.storyManager = storyManager
        }

        func fetchUsername(for story: Story) {
            storyManager.getUser(creatorOf: story)
                .catchAndExit({ error in Logger.error.log(error) })
                .map(\.name)
                .assign(to: &$userName)
        }
    }
}
