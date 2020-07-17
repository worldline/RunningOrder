//
//  Sprints_Previews.swift
//  RunningOrder
//
//  Created by Clément Nonn on 08/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation

extension Sprint {
    enum Previews {
        static let sprints = [
            Sprint(name: "Sprint 1", stories: Story.Previews.stories),
            Sprint(name: "Sprint 2", stories: [])
        ]
    }
}
