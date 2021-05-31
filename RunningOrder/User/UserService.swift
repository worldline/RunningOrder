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

extension UserService {
    enum Error: Swift.Error {
        case noShareFound
        case noShareReferenceFound
    }
}

/// The service responsible of all the Sprint CRUD operation
class UserService {
    let cloudkitContainer = CloudKitContainer.shared

    func fetch(userReference: User.Reference) -> AnyPublisher<User, Swift.Error> {
        cloudkitContainer.cloudContainer.discoverUserIdentity(withUserRecordID: userReference.recordId)
            .map {
                User(
                    reference: userReference,
                    identity: Self.processUserIdentity($0)
                )
            }
            .eraseToAnyPublisher()
    }

    func users(in space: Space) -> AnyPublisher<[User], Swift.Error> {
        guard let shareReference = space.underlyingRecord.share else {
            return Fail(error: Error.noShareReferenceFound).eraseToAnyPublisher()
        }
        let operation = CKFetchRecordsOperation(recordIDs: [shareReference.recordID])
        operation.desiredKeys = ["participants"]

        let configuration = CKOperation.Configuration()
        configuration.qualityOfService = .utility

        operation.configuration = configuration

        cloudkitContainer.database(for: space.zoneId).add(operation)

        return operation.publishers()
            .perRecord
            .print(in: Logger.debug)
            .tryMap { record, _ -> [User] in
                guard let share = record as? CKShare else { throw Error.noShareFound }
                return share.participants
                    .compactMap { $0.userIdentity }
                    .map {
                        User(
                            reference: User.Reference(
                                recordId: $0.userRecordID!
                            ),
                            identity: Self.processUserIdentity($0)
                        )
                    }
            }
            .eraseToAnyPublisher()
    }

    private static func processUserIdentity(_ userIdentity: CKUserIdentity) -> User.Identity {
        if let components = userIdentity.nameComponents {
            return .name(components)
        } else if let emailAddress = userIdentity.lookupInfo?.emailAddress {
            return .email(emailAddress)
        } else {
            return .noIdentity
        }
    }
}
