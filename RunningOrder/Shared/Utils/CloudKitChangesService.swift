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

let changeInformationPreview = Just<ChangeInformation>((toUpdate: [], toDelete: [])).eraseToAnyPublisher()

final class CloudKitChangesService: ObservableObject {
    private unowned let container: CloudKitContainer
    private var currentChangeServerToken: CKServerChangeToken?

    private var cancellables = Set<AnyCancellable>()

    let sprintChangesPublisher = PassthroughSubject<ChangeInformation, Never>()
    let storyChangesPublisher = PassthroughSubject<ChangeInformation, Never>()
    let storyInformationChangesPublisher = PassthroughSubject<ChangeInformation, Never>()

    init(container: CloudKitContainer) {
        self.container = container
    }

    func fetchChanges() {
        let zoneId = container.sharedZoneId
        let operation = CKFetchRecordZoneChangesOperation(
            recordZoneIDs: [zoneId],
            configurationsByRecordZoneID: [zoneId: .init(previousServerChangeToken: currentChangeServerToken)]
        )

        operation.fetchAllChanges = true

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
            .sink { [weak self] updates in self?.handleUpdates(updates: updates) }
            .store(in: &cancellables)

        let tokenChanged = tokenChangesPublisher
            .filter { $0.zoneId == zoneId }
            .map(\.serverToken)

        recordZoneFetchPublisher
            .filter { $0.zoneId == zoneId }
            .map(\.serverToken)
            .catchAndExit { [weak self] error in
                if let error = error as? CKError, error.code == .changeTokenExpired {
                    self?.currentChangeServerToken = nil
                    self?.fetchChanges()
                }
                Logger.error.log(error) // TODO: Error handling
            }
            .merge(with: tokenChanged)
            .assign(to: \.currentChangeServerToken, onStrong: self)
            .store(in: &cancellables)

        container.currentDatabase.add(operation)
    }

    func handleUpdates(updates: [CKRecord.RecordType: ChangeInformation]) {
        for (key, changes) in updates {
            guard let type = RecordType(rawValue: key) else {
                Logger.error.log("unrecognized record type \(key)")
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
                break
            }
        }
    }
}
