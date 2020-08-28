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
    /// A combine operator to ignore all the next values when an error is catched
    /// - Parameter completion: The action to perform when an error is catched
    /// - Returns: The modified publisher
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
    /// A combine assign operator version to prevent strong reference
    /// - Parameters:
    ///   - keyPath: A key path that indicates the property to assign
    ///   - object: A key path that indicates the property to assign
    func assign<Root: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<Root, Self.Output>,
        onStrong object: Root) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }

    /// A combine assign operator version to prevent from strong reference, optional output version
    /// - Parameters:
    ///   - keyPath: A key path that indicates the property to assign
    ///   - object: The object that contains the property
    func assign<Root: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<Root, Self.Output?>,
        onStrong object: Root) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }

    /// A combine operator to append the output value of a publisher to an Array of the same Output type
    /// The operator prevents from strong reference
    /// - Parameters:
    ///   - keyPath: A key path that indicates the property to append
    ///   - object: The object that contains the array property
    func append<Root: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<Root, [Self.Output]>,
        onStrong object: Root) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath].append(value)
        }
    }

    /// A combine operator to append the output value of a publisher to an Optional Array of the same Output type
    /// The operator prevents from strong reference
    /// - Parameters:
    ///   - keyPath: A key path that indicates the property to append
    ///   - object: The object that contains the array property
    func append<Root: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<Root, [Self.Output]?>,
        onStrong object: Root) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath]?.append(value)
        }
    }
}

extension Publisher where Self.Output == Never {
    /// A combine sink version to only receive the completion type when there is no output value
    /// - Parameter receiveFailure: The action to perform in case of failure completion type
    func sink(receiveFailure: @escaping (Failure) -> Void) -> AnyCancellable {
        self.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let failure):
                receiveFailure(failure)
            case .finished:
                break
            }
        })
    }

    /// A combine sink version to ignore receiveValue completion block when Self.Output == Never
    /// - Parameter completion: <#completion description#>
    /// - Returns: <#description#>
    func sink(receiveCompletion completion: @escaping (Subscribers.Completion<Failure>) -> Void) -> AnyCancellable {
        self.sink(receiveCompletion: completion, receiveValue: { _ in })
    }
}
