//
//  UserService.swift
//  RunningOrder
//
//  Created by Clément Nonn on 12/03/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation
import Combine
import CloudKit

/// The service responsible of all the Sprint CRUD operation
class UserService {
    let cloudkitContainer = CloudKitContainer.shared

    func fetch(userReference: UserReference) -> AnyPublisher<User, Swift.Error> {
        cloudkitContainer.container.discoverUserIdentity(withUserRecordID: userReference.recordId)
            .map { identity in
                if let components = identity.nameComponents {
                    Logger.debug.log(components)
                    return User.name(components)
                } else if let emailAddress = identity.lookupInfo?.emailAddress {
                    return User.email(emailAddress)
                } else {
                    return User.noIdentity
                }
            }
            .eraseToAnyPublisher()
    }
}
