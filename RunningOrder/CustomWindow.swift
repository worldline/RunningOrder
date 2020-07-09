//
//  CustomWindow.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Cocoa
import SwiftUI

// toolbar guidance : https://developer.apple.com/documentation/appkit/touch_bar/integrating_a_toolbar_and_touch_bar_into_your_app
final class AppWindowController: NSWindowController, NSToolbarDelegate {
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            NSToolbarItem.Identifier.toggleSidebar,
            NSToolbarItem.Identifier.space,
            NSToolbarItem.Identifier.flexibleSpace,
            NSToolbarItem.Identifier.cloudSharing
        ]
    }
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            NSToolbarItem.Identifier.toggleSidebar,
            NSToolbarItem.Identifier.flexibleSpace,
            NSToolbarItem.Identifier.cloudSharing
        ]
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        let item = NSToolbarItem(itemIdentifier: itemIdentifier)

        return item
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        window?.contentViewController = NSHostingController(rootView: MainView())
    }
}
