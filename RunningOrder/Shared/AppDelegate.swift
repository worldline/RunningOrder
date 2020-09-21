//
//  AppDelegate.swift
//  RunningOrder
//
//  Created by Clément Nonn on 23/06/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Cocoa
import CloudKit
import Combine

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let cloudkitContainer = CloudKitContainer.shared
    var cancellables = Set<AnyCancellable>()
    var spaceManager: SpaceManager?

    func applicationDidFinishLaunching(_ aNotification: Notification) { }

    func application(_ application: NSApplication, userDidAcceptCloudKitShareWith metadata: CKShare.Metadata) {
        let acceptShareOperation = CKAcceptSharesOperation(shareMetadatas: [metadata])
        Logger.verbose.log("user did accept share")
        acceptShareOperation.publishers().perShare.sink(receiveFailure: { error in
            Logger.error.log("error : \(error)")
        }, receiveValue: { [weak self] metadata, _ in
            Logger.verbose.log("acceptShareOperation done")

            if let ownerId = metadata.ownerIdentity.userRecordID?.recordName {
                CloudKitContainer.shared.mode = .shared(ownerName: ownerId)
            } else {
                Logger.error.log("no owner !")
            }

            // Trigger fetch
            self?.spaceManager?.fetchFromShared(metadata.rootRecordID)
        }).store(in: &cancellables)

        let remoteContainer = CKContainer(identifier: metadata.containerIdentifier)

        remoteContainer.add(acceptShareOperation)
    }

    @IBAction func deleteSpace(sender: Any) {
        guard let spaceManager = spaceManager else { return }

        spaceManager.deleteCurrentSpace()

        if !cloudkitContainer.mode.isOwner {
            cloudkitContainer.mode = .owner
        }
    }
}
