//
//  DisposeBab.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 20/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import Combine

class DisposeBag {
    var cancellables: Set<AnyCancellable> = []
}
