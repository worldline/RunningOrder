//
//  Combine+Extensions.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 20/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import Combine

extension Publisher {
    func catchAndExit(_ completion: @escaping (Self.Failure) -> Void) -> AnyPublisher<Self.Output, Never> {
        return self
            .map { output -> Self.Output? in output }
            .catch { err -> Just<Self.Output?> in
                completion(err)
                return Just(nil)
            }
            .filter { output in
                output != nil
            }
            .map { output in output! }
            .eraseToAnyPublisher()
    }
}

extension Publisher where Self.Failure == Never {
    func assign<Root: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<Root, Self.Output>,
        onStrong object: Root) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }

    func assign<Root: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<Root, Self.Output?>,
        onStrong object: Root) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
}
