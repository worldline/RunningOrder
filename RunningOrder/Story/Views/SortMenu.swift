//
//  SortMenu.swift
//  RunningOrder
//
//  Created by Clément Nonn on 13/07/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI

struct SortMenu: View {
    @Binding var selectedSort: Option

    var body: some View {
        Menu {
            ForEach(Option.OptionType.allCases, id: \.rawValue) { optionType in
                Button(optionType.title) {
                    selectedSort = Option(
                        type: optionType,
                        isReversed: optionType == selectedSort.type && !selectedSort.isReversed
                    )
                }
            }
        } label: {
            Image(systemName: "line.horizontal.3.decrease.circle")
        }
    }
}

extension SortMenu {
    struct Option {
        // swiftlint:disable:next nesting
        enum OptionType: String, CaseIterable {
            case epic, name, reference

            var title: LocalizedStringKey {
                switch self {
                case .epic:
                    return "Epic"
                case .name:
                    return "Name"
                case .reference:
                    return "Ticket ID"
                }
            }
        }
        var type: OptionType
        var isReversed: Bool

        func apply(lhs: Story, rhs: Story) -> Bool {
            switch (self.type, isReversed) {
            case (.epic, false):
                return lhs.epic < rhs.epic
            case (.epic, true):
                return lhs.epic > rhs.epic
            case (.name, false):
                return lhs.name < rhs.name
            case (.name, true):
                return lhs.name > rhs.name
            case (.reference, false):
                return lhs.ticketReference < rhs.ticketReference
            case (.reference, true):
                return lhs.ticketReference > rhs.ticketReference
            }
        }
    }
}
