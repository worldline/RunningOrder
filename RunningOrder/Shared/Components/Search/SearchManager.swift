//
//  SearchManager.swift
//  RunningOrder
//
//  Created by Ghita Laoud on 06/04/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation
import Combine

final class SearchManager: ObservableObject {
    @Published var selectedSearchItem: SearchItem?
}
