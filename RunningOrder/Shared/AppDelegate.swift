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
        spaceManager?.acceptShare(metadata: metadata)
    }

    @IBAction func deleteSpace(sender: Any) {
        guard let spaceManager = spaceManager else { return }

        spaceManager.deleteCurrentSpace()
        cloudkitContainer.resetModeIfNeeded()
    }
}
