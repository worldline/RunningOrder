//
//  CKRecordable.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 20/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import CloudKit

/// A protocol which have to be conformed by entities stored in CloudKit to help encoding and decoding from CKRecord type
protocol CKRecordable {
    init(from record: CKRecord) throws
    func encode() throws -> CKRecord
}
