//
//  BasicError.swift
//  RunningOrder
//
//  Created by Clément Nonn on 12/03/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation

enum BasicError: LocalizedError {
    case noValue

    var failureReason: String? {
        switch self {
        case .noValue:
            return "no value found"
        }
    }
}
