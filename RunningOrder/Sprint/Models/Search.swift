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
        case filter

        var icon: String {
            switch self {
            case .story:
                return "list.bullet.rectangle"
            case .epic:
                return "folder.fill"
            case .people:
                return "person.circle"
            case .filter:
                return "text.magnifyingglass"
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

enum SearchItem {
    case story(Story)
    case epic(String)
    case filter(String)
    case people(User)

    var name: String {
        switch self {
        case .epic(let epic):
            return epic
        case .filter(_):
            return "Filter..."
        case .story(let story):
            return story.name
        case .people(let user):
            return user.identity.name ?? "No Identity"
        }
    }
}

extension SearchItem: Equatable {
    static func == (lhs: SearchItem, rhs: SearchItem) -> Bool {
        lhs.name == rhs.name
    }
}

extension SearchItem: Hashable { }

extension SearchItem: Identifiable {
    var id: String { name }
}
