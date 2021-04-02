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
    enum SectionType: String {
        case story // Jira reference + story's name
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

struct SearchItem: Identifiable, Hashable {
    static func == (lhs: SearchItem, rhs: SearchItem) -> Bool {
        lhs.name == rhs.name
    }

    var id: UUID { return UUID() }
    var name: String
    var icon: String
    var type: SearchSection.SectionType
    var relatedStory: Story?
}
