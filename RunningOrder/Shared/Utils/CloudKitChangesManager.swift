//
//  CloudKitChangesManager.swift
//  RunningOrder
//
//  Created by Clément Nonn on 05/10/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import Combine
import CloudKit

final class CloudKitChangesManager {
    private unowned let container: CloudKitContainer
    private unowned let sprintManager: SprintManager
    private unowned let storyManager: StoryManager
    private unowned let storyInformationManager: StoryInformationManager

    private var currentChangeServerToken: CKServerChangeToken?

    private var cancellables = Set<AnyCancellable>()

    init(container: CloudKitContainer, sprintManager: SprintManager, storyManager: StoryManager, storyInformationManager: StoryInformationManager) {
        self.container = container
        self.sprintManager = sprintManager
        self.storyManager = storyManager
        self.storyInformationManager = storyInformationManager
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
            .map { records, toDelete -> ([CKRecord.RecordType: [CKRecord]], [CKRecord.RecordType: [CKRecord.ID]]) in
                let idsToDelete = toDelete.map { $0.0 }
                let toUpdate = records.filter { !idsToDelete.contains($0.recordID) }

                let groupedUpdates = [CKRecord.RecordType: [CKRecord]](grouping: toUpdate, by: { record in record.recordType })
                let groupedDeletion = [CKRecord.RecordType: [(CKRecord.ID, CKRecord.RecordType)]](grouping: toDelete, by: { element in return element.1 }).mapValues { array -> [CKRecord.ID] in return array.map { $0.0 } }
                return (groupedUpdates, groupedDeletion)
            }
            .sink { [weak self] updates in
                self?.handle(recordsToUpdate: updates.0)
                self?.handle(recordIdsToDelete: updates.1)
            }
            .store(in: &cancellables)

        let tokenChanged = tokenChangesPublisher
            .filter { $0.0 == zoneId }
            .map(\.1)

        recordZoneFetchPublisher
            .filter { $0.0 == zoneId }
            .map(\.1)
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

    private func handle(recordsToUpdate: [CKRecord.RecordType: [CKRecord]]) {
        for (recordType, records) in recordsToUpdate {
            guard let type = RecordType(rawValue: recordType) else {
                Logger.error.log("unrecognized record type \(recordType)")
                continue
            }

            switch type {
            case .sprint:
                self.sprintManager.updateData(with: records)
            case .story:
                self.storyManager.updateData(with: records)
            case .storyInformation:
                self.storyInformationManager.updateData(with: records)
            case .space:
                break
            }
        }
    }

    private func handle(recordIdsToDelete: [CKRecord.RecordType: [CKRecord.ID]]) {
        for (recordType, ids) in recordIdsToDelete {
            guard let type = RecordType(rawValue: recordType) else {
                Logger.error.log("unrecognized record type \(recordType)")
                continue
            }
            switch type {
            case .sprint:
                self.sprintManager.deleteData(recordIds: ids)
            case .story:
                self.storyManager.deleteData(recordIds: ids)
            case .storyInformation:
                self.storyInformationManager.deleteData(recordIds: ids)
            case .space:
                break
            }
        }
    }
}
