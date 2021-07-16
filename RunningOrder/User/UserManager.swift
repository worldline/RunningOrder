//
//  UserManager.swift
//  RunningOrder
//
//  Created by Clément Nonn on 20/05/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation
import Combine

final class UserManager: ObservableObject {
    @Published private(set) var users: Set<User>

    private let userService: UserService
    private var cancellables = Set<AnyCancellable>()

    init(userService: UserService) {
        self.userService = userService
        users = []
    }

    func fetchUser(for space: Space) {
        userService.users(in: space)
            .catchAndExit { error in Logger.warning.log(error) } // This is not really an error : space could be not shared at all
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newUsers in
                self?.users.formUnion(newUsers)
            })
            .store(in: &cancellables)
    }

    func identity(for reference: User.Reference) -> AnyPublisher<User.Identity, Never> {
        if let storedIdentity = users.first(where: { $0.reference == reference })?.identity {
            return Just(storedIdentity).eraseToAnyPublisher()
        } else {
            return userService
                .fetch(userReference: reference)
                .receive(on: DispatchQueue.main)
                .handleEvents(receiveOutput: {
                    self.users.insert($0)
                })
                .map(\.identity)
                .catch { error -> Just<User.Identity> in
                    Logger.error.log(error)
                    return Just(User.Identity.noIdentity)
                }
                .eraseToAnyPublisher()
        }
    }
}

extension UserManager {
    static var preview = UserManager(userService: UserService())
}
