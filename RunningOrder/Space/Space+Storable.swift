//
//  Space+Storable.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/06/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation
import CloudKit

extension Space: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        let record = try container.decode(ObjectCodableWrapper<CKRecord>.self).wrappedValue

        self.init(underlyingRecord: record)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(ObjectCodableWrapper<CKRecord>(wrappedValue: self.underlyingRecord))
    }
}
