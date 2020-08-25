//
//  CKRecordable.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 20/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import CloudKit

protocol CKRecordable {
    init(from record: CKRecord) throws
    func encode(zoneId: CKRecordZone.ID) -> CKRecord
}
