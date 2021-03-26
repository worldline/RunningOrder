//
//  UserReference.swift
//  RunningOrder
//
//  Created by Clément Nonn on 12/03/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation
import CloudKit

struct UserReference {
    let recordId: CKRecord.ID
}

extension UserReference: Equatable {}
extension UserReference: Hashable {}
