//
//  CloudSharingHandler.swift
//  RunningOrder
//
//  Created by Clément Nonn on 02/02/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import CloudKit
import Combine
import AppKit

class CloudSharingHandler: NSObject {
    init(spaceManager: SpaceManager) {
        self.spaceManager = spaceManager
    }

    let spaceManager: SpaceManager
    private var share: CKShare?

    var cancellables = Set<AnyCancellable>()

    func performCloudSharing() {
        guard let space = self.spaceManager.space else { return }

        if space.isShared {
            displayAlreadySharing()
        } else {
            displayNewShare()
        }
    }

    func displayNewShare() {
        let itemProvider = NSItemProvider()
        let container = CloudKitContainer.shared.container

        itemProvider.registerCloudKitShare { [weak self] completion in
            guard let self = self else { return }

            self.spaceManager.saveAndShare()
                .sink(receiveFailure: { error in
                    completion(nil, container, error)
                }, receiveValue: { [weak self] share in
                    self?.share = share
                    completion(share, container, nil)
                })
                .store(in: &self.cancellables)
        }

        let sharingService = NSSharingService(named: .cloudSharing)!
        sharingService.delegate = self
        sharingService.perform(withItems: [itemProvider])
    }

    func displayAlreadySharing() {
        self.spaceManager.getShare()
            .receive(on: DispatchQueue.main)
            .sink(receiveFailure: { error in
                Logger.error.log(error)
            }, receiveValue: { [weak self] share in
                self?.share = share
                let itemProvider = NSItemProvider()
                itemProvider.registerCloudKitShare(share, container: CloudKitContainer.shared.container)

                let sharingService = NSSharingService(named: .cloudSharing)!
                sharingService.delegate = self
                sharingService.perform(withItems: [itemProvider])
            })
            .store(in: &cancellables)
    }
}

extension CloudSharingHandler: NSCloudSharingServiceDelegate {}
