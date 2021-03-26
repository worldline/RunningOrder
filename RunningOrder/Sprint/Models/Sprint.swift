//
//  Sprint.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation

struct Sprint {
    let spaceId: Space.ID
    let number: Int
    let name: String
    let colorIdentifier: String
}

extension Sprint {
    // swiftlint:disable:next type_name
    typealias ID = String
    var id: ID { return "\(self.name)\(self.number)" }
}

extension Sprint: Equatable { }
extension Sprint: Hashable { }

struct SearchSection: Identifiable {
    var id: UUID { return UUID() }
    var name: String
    var items: [SearchItem]
}

extension SearchSection {
    enum Name: String {
        case story // Jira reference + storyname
        case epic // epic name
        case people // story's creator name

        var iconName: String {
            switch self {
            case .story:
                return "list.bullet.rectangle"
            case .epic:
                return "folder.fill"
            case .people:
                return "person.circle"
            }
        }
    }
}

struct SearchItem: Identifiable {
    var id: UUID { return UUID() }
    var name: String
    var icon: String
}
