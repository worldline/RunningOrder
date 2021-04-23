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

typealias ChangeInformation = (toUpdate: [CKRecord], toDelete: [CKRecord.ID])

final class CloudKitChangesService: ObservableObject {
    private unowned let container: CloudKitContainer
    private var currentChangeServerTokens: [CKRecordZone.ID: CKServerChangeToken] = [:]
    private var databaseChangesServerToken: CKServerChangeToken?

    private var cancellables = Set<AnyCancellable>()

    let sprintChangesPublisher = PassthroughSubject<ChangeInformation, Never>()
    let storyChangesPublisher = PassthroughSubject<ChangeInformation, Never>()
    let storyInformationChangesPublisher = PassthroughSubject<ChangeInformation, Never>()
    let spaceChangesPublisher = PassthroughSubject<ChangeInformation, Never>()

    init(container: CloudKitContainer) {
        self.container = container
    }

    func initialFetch() {
        self.fetchChanges(on: container.ownedZoneId)
        container.owners
            .forEach(self.fetchChanges(on:))
    }

    func refreshAll() {
        Logger.debug.log("refresh")
        self.fetchDatabaseChanges(in: .private)
        self.fetchDatabaseChanges(in: .shared)
    }

    func fetchDatabaseChanges(in scope: CKDatabase.Scope) {
        let operation = CKFetchDatabaseChangesOperation(previousServerChangeToken: databaseChangesServerToken)

        let (fetchDatabaseChangesCompletion, changeTokenUpdated, recordZoneWithIDChanged, _, _) = operation.publishers()

        // update the token
        fetchDatabaseChangesCompletion
            .catchAndExit { [weak self] error in
                if let error = error as? CKError, error.code == .changeTokenExpired {
                    self?.databaseChangesServerToken = nil
                    self?.fetchDatabaseChanges(in: scope)
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
                for zoneId in zoneIds {
                    self?.fetchChanges(on: zoneId)
                }
            }
            .store(in: &cancellables)

        container.cloudContainer.database(with: scope).add(operation)
    }

    func fetchChanges(on zoneId: CKRecordZone.ID) {
        let token = currentChangeServerTokens[zoneId]
        let operation = CKFetchRecordZoneChangesOperation(
            recordZoneIDs: [zoneId],
            configurationsByRecordZoneID: [zoneId: .init(previousServerChangeToken: token)]
        )

        operation.qualityOfService = .userInteractive

        let (_, recordPublisher, recordDeletedPublisher, tokenChangesPublisher, recordZoneFetchPublisher) = operation.publishers()

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
                if let error = error as? CKError, error.code == .changeTokenExpired {
                    self?.currentChangeServerTokens[zoneId] = nil
                    self?.fetchChanges(on: zoneId)
                }
                Logger.error.log(error) // TODO: Error handling
            }
            .merge(with: tokenChanged)
            .assign(to: \.currentChangeServerTokens[zoneId], onStrong: self)
            .store(in: &cancellables)

        container.database(for: zoneId).add(operation)
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
