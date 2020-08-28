//
//  AppDelegate.swift
//  RunningOrder
//
//  Created by Clément Nonn on 23/06/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let cloudkitContainer = CloudKitContainer.shared

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // If the user has no CloudKit custom zone yet we create it
        cloudkitContainer.createCustomZoneIfNeeded()
    }
}
