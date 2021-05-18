//
//  SearchManager.swift
//  RunningOrder
//
//  Created by Ghita Laoud on 06/04/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

final class SearchManager: ObservableObject {
    @Published var selectedSearchItem: SearchItem?

    @Published var currentSearchText: String = ""

    var isItemSelected: Bool { selectedSearchItem != nil }

    func resetSearch() {
        currentSearchText = ""
        selectedSearchItem = nil
    }

    func selectItem(_ item: SearchItem) {
        currentSearchText = ""
        selectedSearchItem = item
    }

//    var selectedItemType: SearchSection.SectionType? {
//        return selectedSearchItem?.type
//    }
}

extension SearchManager {
    static let preview = SearchManager()
}
