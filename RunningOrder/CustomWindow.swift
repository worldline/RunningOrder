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
            .toggleSidebar,
            .space,
            .addStory,
            .flexibleSpace,
            .cloudSharing
        ]
    }
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .toggleSidebar,
            .addStory,
            .flexibleSpace,
            .cloudSharing
        ]
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {

        var toolbarItem: NSToolbarItem = NSToolbarItem()

        if itemIdentifier == NSToolbarItem.Identifier.addStory {
            toolbarItem = customToolbarButtonItem(itemForItemIdentifier: itemIdentifier.rawValue,
                                                  label: NSLocalizedString("Add a story", comment: ""),
                                                  paletteLabel: NSLocalizedString("Add a story", comment: ""),
                                                  toolTip: NSLocalizedString("Add a story", comment: ""),
                                                  iconImageName: NSImage.addTemplateName,
                                                  action: #selector(addStoryActionPlaceHolder))!
        }

        return toolbarItem
    }

    func toolbarWillAddItem(_ notification: Notification) {
        let item = notification.userInfo!["item"] as? NSToolbarItem
        if let item = item {
            if item.itemIdentifier == NSToolbarItem.Identifier.toggleSidebar {
                item.action = #selector(toggleSidebar)
            }
        }
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        window?.contentViewController = NSHostingController(rootView: MainView())
    }

    func customToolbarButtonItem(
        itemForItemIdentifier itemIdentifier: String,
        label: String,
        paletteLabel: String,
        toolTip: String,
        iconImageName: String,
        action: Selector) -> NSToolbarItem? {

        let toolbarItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(rawValue: itemIdentifier))

        let iconImage = NSImage(named: iconImageName)

        let button = NSButton(frame: NSRect(x: 0, y: 0, width: 40, height: 40))
        button.title = ""
        button.image = iconImage
        button.bezelStyle = .texturedRounded

        button.action = action
        toolbarItem.view = button
        toolbarItem.label = label
        toolbarItem.paletteLabel = paletteLabel
        toolbarItem.toolTip = toolTip
        toolbarItem.target = self

        return toolbarItem
    }

// TODO change these lines in the future
    @objc func toggleSidebar(_ sender: Any) {
        ((window?.contentView?.subviews.first?.subviews.first?.subviews.first as? NSSplitView)?.delegate as? NSSplitViewController)?.toggleSidebar(self)
    }

    @objc func addStoryActionPlaceHolder() {
        print("addStory toolbarbutton clicked")
    }
}

private extension NSToolbarItem.Identifier {
    static let addStory: NSToolbarItem.Identifier = NSToolbarItem.Identifier(rawValue: "AddStory")
}
