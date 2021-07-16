//
//  AppStateManager.swift
//  RunningOrder
//
//  Created by Clément Nonn on 29/03/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

extension AppStateManager {
    enum State {
        case idle
        case loading(Progress)
        case error(Swift.Error)
        case spaceCreation
        case spaceSelected(Space)
    }
}

struct ErrorTrace {
    struct Location: CustomDebugStringConvertible {
        let file: String
        let line: Int
        let function: String

        static func collect(file: String = #fileID, line: Int = #line, function: String = #function) -> Location {
            self.init(file: file, line: line, function: function)
        }

        var debugDescription: String {
            "\(file):\(line) in `\(function)`"
        }
    }

    let error: Error
    let location: Location
    let date = Date()

    var lineDescription: String {
        return error.localizedDescription
    }

    var fullDescription: String {
        return """
        Error at \(location.debugDescription).
        \(error.localizedDescription) -- \(error)
        """
    }
}

extension NotificationCenter {
    func postError(_ error: Error, file: String = #fileID, line: Int = #line, function: String = #function) {
        self.post(
            name: AppStateManager.errorReportingNotification,
            object: nil,
            userInfo: [
                "trace": ErrorTrace(
                    error: error,
                    location: ErrorTrace.Location(
                        file: file,
                        line: line,
                        function: function
                    )
                )
            ]
        )
    }
}

final class AppStateManager: ObservableObject {
    @Published var currentState: State = .idle
    @Published var currentLoading: Progress?
    @Published var errors: [ErrorTrace] = []

    @Published var enabledFeatures: [FeatureFlag] = []

    @AppStorage("currentSpaceName") private var storedSpaceName: String?

    private unowned var changesService: CloudKitChangesService

    private var spaceNameCancellable: AnyCancellable?
    private var errorReportingCancellable: AnyCancellable?

    static let errorReportingNotification: Notification.Name = Notification.Name("errorReporting")

    init(changesService: CloudKitChangesService) {
        self.changesService = changesService
        Timer
            .publish(every: 180, on: .main, in: .default)
            .autoconnect()
            .map { _ in
                changesService.refreshAll()
            }
            .assign(to: &$currentLoading)

        $currentLoading
            .unwrap()
            .flatMap { progress in
                progress.publisher(for: \.isFinished)
            }
            .filter { $0 }
            .map { _ -> Progress? in
                return nil
            }
            .delay(for: 1, scheduler: DispatchQueue.main)
            .assign(to: &$currentLoading)

        spaceNameCancellable = $currentState
            .compactMap {
                if case .spaceSelected(let space) = $0 {
                    return space.name
                } else {
                    return nil
                }
            }
            .assign(to: \.storedSpaceName, onStrong: self)

        errorReportingCancellable = NotificationCenter.default.publisher(for: Self.errorReportingNotification)
            .map(\.userInfo)
            .sink(receiveValue: { userInfo in
                if let trace = userInfo?["trace"] as? ErrorTrace {
                    self.reportErrorTrace(trace)
                } else if let error = userInfo?["error"] as? Error {
                    self.reportError(error)
                }
            })
    }

    // MARK: - Refreshing

    func refreshAll() {
        currentLoading = changesService.refreshAll(qos: .userInitiated)
    }

    func fetchFirstSpace(in spaceManager: SpaceManager, withProgress progress: Progress) {
        self.currentState = .loading(progress)

        let progressEndedPublisher: AnyPublisher<Bool, Never>

        if progress.isIndeterminate {
            progressEndedPublisher = Just(true)
                .eraseToAnyPublisher()
        } else {
            progressEndedPublisher = progress
                .publisher(for: \.isFinished)
                .filter { $0 }
                .first()
                .delay(for: 0.5, scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        }

        spaceManager
            .$availableSpaces
            .combineLatest(progressEndedPublisher)
            .map(\.0)
            .first(where: { // only the first change to avoid re-updating each time a new space is fetched, but we still wait if the stored space is not in the first stored spaces fetched
                if let storedSpaceName = self.storedSpaceName {
                    return $0.contains(where: { space in space.name == storedSpaceName })
                } else {
                    return true
                }
            })
            .map { firstSpaces in
                if let storedSpaceName = self.storedSpaceName,
                   let foundSpace = firstSpaces.first(where: { $0.name == storedSpaceName }) {
                    return .spaceSelected(foundSpace)
                } else if let foundSpace = firstSpaces.last {
                    return .spaceSelected(foundSpace)
                } else {
                    return .spaceCreation
                }
            }
            .assign(to: &$currentState)
    }

    // MARK: - Error Reporting

    func reportError(_ error: Error, file: String = #fileID, line: Int = #line, function: String = #function) {
        let trace = ErrorTrace(
            error: error,
            location: ErrorTrace.Location(
                file: file,
                line: line,
                function: function
            )
        )

        self.reportErrorTrace(trace)
    }

    func reportErrorTrace(_ trace: ErrorTrace) {
        Logger.error.log(trace.fullDescription)

        self.errors.append(trace)
    }
}

extension AppStateManager {
    static func preview(currentLoading: Progress? = nil, currentState: State = .idle) -> AppStateManager {
        let manager = AppStateManager(changesService: CloudKitChangesService(container: CloudKitContainer.shared))
        manager.currentState = currentState
        manager.currentLoading = currentLoading

        return manager
    }
}
