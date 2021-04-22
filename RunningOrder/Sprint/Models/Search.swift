//
//  Search.swift
//  RunningOrder
//
//  Created by Ghita Laoud on 22/04/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation

struct SearchSection {
    var type: SearchSection.SectionType
    var items: Set<SearchItem>
}

extension SearchSection {
    enum SectionType: String {
        case story // Jira reference + story's name
        case epic // epic name
        case people // story's creator name

        var icon: String {
            switch self {
            case .story:
                return "list.bullet.rectangle"
            case .epic:
                return "folder.fill"
            case .people:
                return "person.circle"
            }
        }

        var title: String {
            return self.rawValue.uppercased()
        }
    }
}

extension SearchSection: Identifiable {
    var id: String { type.title }
}

struct SearchItem: Hashable {
    var name: String
    var icon: String
    var type: SearchSection.SectionType
    var relatedStory: Story?

    static func == (lhs: SearchItem, rhs: SearchItem) -> Bool {
        lhs.name == rhs.name
    }
}

extension SearchItem: Identifiable {
    var id: String { name }
}
