//
//  Logger.swift
//  RunningOrder
//
//  Created by Clément Nonn on 23/09/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation

enum Logger {
    case verbose
    case debug
    case error
    case warning

    private var icon: String {
        switch self {
        case .debug:
            return "🟣"
        case .verbose:
            return "🟡"
        case .warning:
            return "🟠"
        case .error:
            return "🔴"
        }
    }

    func log(_ value: Any, file: String = #file, line: Int = #line, function: String = #function) {
        print("\(self.icon) \(file):\(line) \(function) - \(value)")
    }
}
