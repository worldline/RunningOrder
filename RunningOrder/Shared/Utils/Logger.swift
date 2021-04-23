//
//  Logger.swift
//  RunningOrder
//
//  Created by Clément Nonn on 23/09/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation

enum Logger: CaseIterable {
    case verbose
    case debug
    case error
    case warning

    fileprivate var icon: String {
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

    var title: String {
        switch self {
        case .debug:
            return "Debug"
        case .verbose:
            return "Verbose"
        case .warning:
            return "Warning"
        case .error:
            return "Error"
        }
    }

    static var disabledLevels: [Logger] = []

    func log(_ value: Any, file: String = #fileID, line: Int = #line, function: String = #function) {
        guard !Logger.disabledLevels.contains(self) else { return }

        print("\(self.icon) \(file):\(line) \(function) - \(value)")
    }
}

import Combine

extension Publisher {
    func print(in logger: Logger, file: String = #fileID, line: Int = #line, function: String = #function) -> Publishers.Print<Self> {
        self.print("\(logger.icon) \(file):\(line) \(function)")
    }
}
