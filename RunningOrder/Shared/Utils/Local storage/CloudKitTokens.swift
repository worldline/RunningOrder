//
//  CloudKitTokens.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/06/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation
import Combine

import CloudKit

struct CloudKitTokens: Codable {
    var databaseChangesServerToken: CKServerChangeToken? {
        _databaseChangesServerToken?.wrappedValue
    }

    private let _databaseChangesServerToken: ObjectCodableWrapper<CKServerChangeToken>?

    var currentChangeServerTokens: [CKRecordZone.ID: CKServerChangeToken] {
        let unwrappedTokens = _currentChangeServerTokens.map({ key, value in
            (key.wrappedValue, value.wrappedValue)
        })

        return Dictionary(uniqueKeysWithValues: unwrappedTokens)
    }

    private let _currentChangeServerTokens: [ObjectCodableWrapper<CKRecordZone.ID>: ObjectCodableWrapper<CKServerChangeToken>]

    init(databaseChangesServerToken: CKServerChangeToken?, currentChangeServerTokens: [CKRecordZone.ID: CKServerChangeToken]) {
        if let databaseToken = databaseChangesServerToken {
            _databaseChangesServerToken = ObjectCodableWrapper<CKServerChangeToken>(wrappedValue: databaseToken)
        } else {
            _databaseChangesServerToken = nil
        }

        let wrappedTokens = currentChangeServerTokens.map { key, value in
            (ObjectCodableWrapper(wrappedValue: key), ObjectCodableWrapper(wrappedValue: value))
        }
        _currentChangeServerTokens = Dictionary(uniqueKeysWithValues: wrappedTokens)
    }
}

extension CloudKitTokens: Storable {}
