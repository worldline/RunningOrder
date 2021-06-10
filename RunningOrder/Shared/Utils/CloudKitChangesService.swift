//
//  CloudKitChangesService.swift
//  RunningOrder
//
//  Created by Clément Nonn on 05/10/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import Combine
import CloudKit

extension CKDatabase.Scope {
    var name: String {
        switch self {
        case .public:
            return "Public Database"
        case .private:
            return "Private Database"
        case .shared:
            return "Shared Database"
        @unknown default:
            return "Unknown Database"
        }
    }
}

typealias ChangeInformation = (toUpdate: [CKRecord], toDelete: [CKRecord.ID])

final class CloudKitChangesService: ObservableObject {
    private unowned let container: CloudKitContainer
    @Published private(set) var currentChangeServerTokens: [CKRecordZone.ID: CKServerChangeToken] = [:]
    @Published private(set) var databaseChangesServerToken: CKServerChangeToken?

    @Stored(fileName: "tokens.json", directory: .applicationSupportDirectory) private var storedTokens: CloudKitTokens?

    private var cancellables = Set<AnyCancellable>()

    let sprintChangesPublisher = PassthroughSubject<ChangeInformation, Never>()
    let storyChangesPublisher = PassthroughSubject<ChangeInformation, Never>()
    let storyInformationChangesPublisher = PassthroughSubject<ChangeInformation, Never>()
    let spaceChangesPublisher = PassthroughSubject<ChangeInformation, Never>()

    init(container: CloudKitContainer) {
        self.container = container

        currentChangeServerTokens = storedTokens?.currentChangeServerTokens ?? [:]
        databaseChangesServerToken = storedTokens?.databaseChangesServerToken

        self.$databaseChangesServerToken
            .combineLatest(self.$currentChangeServerTokens, CloudKitTokens.init)
            .assign(to: \.storedTokens, onStrong: self)
            .store(in: &cancellables)

        self.checkNotifications()
    }

    private func checkNotifications() {
        let operation = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()

        operation
            .publisher()
            .sink(
                receiveFailure: { error in Logger.error.log(error) },
                receiveValue: { [weak self] zones in
                    for (zoneId, _) in zones {
                        self?.container.enableNotificationsIfNeeded(for: zoneId)
                    }
                }
            )
            .store(in: &cancellables)

        container.cloudContainer.database(with: .shared).add(operation)
    }

    /// Fetch the database changes first, then fetch the changes in the zones with the ids found in the changes of the database
    @discardableResult func refreshAll() -> Progress {
        Logger.debug.log("refresh")

        let progress = Progress(totalUnitCount: 2)
        progress.addChild(self.fetchDatabaseChanges(in: .private), withPendingUnitCount: 1)
        progress.addChild(self.fetchDatabaseChanges(in: .shared), withPendingUnitCount: 1)

        return progress
    }

    func fetchDatabaseChanges(in scope: CKDatabase.Scope) -> Progress {
        let operation = CKFetchDatabaseChangesOperation(previousServerChangeToken: databaseChangesServerToken)
        let progress = Progress(totalUnitCount: 0)
        let (fetchDatabaseChangesCompletion, changeTokenUpdated, recordZoneWithIDChanged, _, _) = operation.publishers()

        // update the token
        fetchDatabaseChangesCompletion
            .catchAndExit { [weak self] error in
                if let self = self,
                   let error = error as? CKError,
                   error.code == .changeTokenExpired {
                    self.databaseChangesServerToken = nil
                    progress.addChild(self.fetchDatabaseChanges(in: scope), withPendingUnitCount: 0)
                } else {
                    progress.cancel()
                }
                Logger.error.log(error) // TODO: Error handling
            }
            .map(\.token)
            .compactMap { $0 }
            .merge(with: changeTokenUpdated)
            .assign(to: \.databaseChangesServerToken, onStrong: self)
            .store(in: &cancellables)

        recordZoneWithIDChanged
            .collect()
            .sink { [weak self] zoneIds in
                guard !zoneIds.isEmpty, let self = self else {
                    progress.totalUnitCount = 1
                    progress.completedUnitCount = 1
                    return
                }
                progress.totalUnitCount = Int64(zoneIds.count)
                for zoneId in zoneIds {
                    progress.addChild(self.fetchChanges(on: zoneId), withPendingUnitCount: 1)
                }
            }
            .store(in: &cancellables)

        container.cloudContainer.database(with: scope).add(operation)
        return progress
    }

    func fetchChanges(on zoneId: CKRecordZone.ID) -> Progress {
        let progress = Progress(totalUnitCount: 5)
        let token = currentChangeServerTokens[zoneId]
        let operation = CKFetchRecordZoneChangesOperation(
            recordZoneIDs: [zoneId],
            configurationsByRecordZoneID: [zoneId: .init(previousServerChangeToken: token)]
        )

        operation.qualityOfService = .userInteractive

        let (fetchRecordZoneChangesCompletion, recordPublisher, recordDeletedPublisher, tokenChangesPublisher, recordZoneFetchPublisher) = operation.publishers()

        fetchRecordZoneChangesCompletion
            .handleEvents(receiveCompletion: { _ in progress.completedUnitCount += 1 })
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    Logger.error.log(error)
                case .finished:
                    break
                }
            })
            .store(in: &cancellables)

        Publishers.CombineLatest(recordPublisher.collect(), recordDeletedPublisher.collect())
            .map { records, toDelete -> ([CKRecord.RecordType: ChangeInformation]) in
                let idsToDelete = toDelete.map { $0.recordId }
                let toUpdate = records.filter { !idsToDelete.contains($0.recordID) }

                let groupedUpdates = [CKRecord.RecordType: [CKRecord]](grouping: toUpdate, by: { record in record.recordType })
                let groupedDeletion = [CKRecord.RecordType: [(recordId: CKRecord.ID, recordType: CKRecord.RecordType)]](grouping: toDelete, by: { element in return element.recordType })
                    .mapValues { array -> [CKRecord.ID] in return array.map { $0.recordId } }

                return groupedUpdates.combine(with: groupedDeletion) { updates, deletions -> ChangeInformation in
                    (updates ?? [], deletions ?? [])
                }
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCompletion: { _ in progress.completedUnitCount += 2 })
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    Logger.debug.log("call finished")
                    if self.firstCallSpaceEmpty {
                        self.spaceChangesPublisher.send((toUpdate: [], toDelete: []))
                        self.firstCallSpaceEmpty = false
                    }

                case .failure(let error):
                    Logger.error.log("error : \(error)") // TODO: Error handling
                }
            }, receiveValue: { [weak self] updates in self?.handleUpdates(updates: updates) })
            .store(in: &cancellables)

        let tokenChanged = tokenChangesPublisher
            .filter { $0.zoneId == zoneId }
            .map(\.serverToken)

        recordZoneFetchPublisher
            .filter { $0.zoneId == zoneId }
            .map(\.serverToken)
            .catchAndExit { [weak self] error in
                if let self = self,
                   let error = error as? CKError,
                   error.code == .changeTokenExpired {
                    self.currentChangeServerTokens[zoneId] = nil
                    progress.addChild(self.fetchChanges(on: zoneId), withPendingUnitCount: 5)
                } else {
                    progress.cancel()
                }
                Logger.error.log(error) // TODO: Error handling
            }
            .merge(with: tokenChanged)
            .handleEvents(receiveCompletion: { _ in progress.completedUnitCount += 2 })
            .assign(to: \.currentChangeServerTokens[zoneId], onStrong: self)
            .store(in: &cancellables)

        container.database(for: zoneId).add(operation)
        return progress
    }

    private var firstCallSpaceEmpty = true

    func handleUpdates(updates: [CKRecord.RecordType: ChangeInformation]) {
        for (key, changes) in updates {
            guard let type = RecordType(rawValue: key) else {
                if key != "cloudkit.share" {
                    Logger.error.log("unrecognized record type \(key)")
                }
                continue
            }

            switch type {
            case .sprint:
                self.sprintChangesPublisher.send(changes)
            case .story:
                self.storyChangesPublisher.send(changes)
            case .storyInformation:
                self.storyInformationChangesPublisher.send(changes)
            case .space:
                self.spaceChangesPublisher.send(changes)
                self.firstCallSpaceEmpty = false
            }
        }
    }
}
