//
//  FileManager+SymbolicFile.swift
//  RunningOrder
//
//  Created by Clément Nonn on 13/07/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation

extension FileManager {
    func isSymbolicFileExist(at path: String) -> Bool {
        do {
            let attributes = try self.attributesOfItem(atPath: path)
            let type = attributes[.type] as? FileAttributeType

            return type == .typeSymbolicLink
        } catch {
            Logger.verbose.log("didn't find attributes for file at \(path) : \(error)")
            return false
        }
    }
}
