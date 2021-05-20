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

        private unowned var userManager: UserManager

        init(userManager: UserManager) {
            self.userManager = userManager
        }

        func fetchUsername(for story: Story) {
            guard let reference = story.creatorReference else { return }

            userManager.identity(for: reference)
                .map(\.name)
                .assign(to: &$userName)
        }
    }
}
