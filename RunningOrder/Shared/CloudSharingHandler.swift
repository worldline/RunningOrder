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
    init(spaceManager: SpaceManager, space: Space) {
        self.spaceManager = spaceManager
        self.space = space
    }

    let spaceManager: SpaceManager
    let space: Space
    private var share: CKShare?

    var cancellables = Set<AnyCancellable>()

    func performCloudSharing() {
        if space.isShared {
            displayAlreadySharing()
        } else {
            displayNewShare()
        }
    }

    func displayNewShare() {
        let itemProvider = NSItemProvider()
        let container = CloudKitContainer.shared.cloudContainer

        itemProvider.registerCloudKitShare { [weak self] completion in
            guard let self = self else { return }

            self.spaceManager.saveAndShare(self.space)
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
        self.spaceManager.getShare(space)
            .receive(on: DispatchQueue.main)
            .sink(receiveFailure: { error in
                Logger.error.log(error)
            }, receiveValue: { [weak self] share in
                self?.share = share
                let itemProvider = NSItemProvider()
                itemProvider.registerCloudKitShare(share, container: CloudKitContainer.shared.cloudContainer)

                let sharingService = NSSharingService(named: .cloudSharing)!
                sharingService.delegate = self
                sharingService.perform(withItems: [itemProvider])
            })
            .store(in: &cancellables)
    }
}

extension CloudSharingHandler: NSCloudSharingServiceDelegate {}
