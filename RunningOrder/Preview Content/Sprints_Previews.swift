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
            Sprint(number: 1, name: "Sprint", color: .init(0x2FBAD5), stories: Story.Previews.stories),
            Sprint(number: 2, name: "Sprint", color: .init(0x23915B), stories: [])
        ]
    }
}
