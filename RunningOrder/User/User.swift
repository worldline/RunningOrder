//
//  User.swift
//  RunningOrder
//
//  Created by Clément Nonn on 12/03/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation

enum User {
    case name(PersonNameComponents)
    case email(String)
    case noIdentity

    var name: String? {
        switch self {
        case .noIdentity:
            return nil
        case .email(let email):
            return email
        case .name(let components):
            return PersonNameComponentsFormatter.localizedString(from: components, style: .default)
        }
    }
}
