//
//  DisposeBab.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 20/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import Combine

/// An usefull class to help SwiftUI views store cancellables and consume Combine publishers
class DisposeBag {
    var cancellables: Set<AnyCancellable> = []
}
