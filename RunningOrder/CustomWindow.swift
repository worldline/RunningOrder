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
final class AppWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        window?.contentViewController = NSHostingController(rootView: MainView())
    }
}

extension AppWindowController: NSToolbarDelegate, NSToolbarItemValidation {
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

        var toolbarItem = NSToolbarItem()

        if itemIdentifier == .addStory {
            toolbarItem = customToolbarButtonItem(itemIdentifier: itemIdentifier.rawValue,
                                                  label: NSLocalizedString("Add a story", comment: ""),
                                                  paletteLabel: NSLocalizedString("Add a story", comment: ""),
                                                  toolTip: NSLocalizedString("Add a story", comment: ""),
                                                  iconImageName: NSImage.addTemplateName,
                                                  action: #selector(addStoryActionPlaceHolder))
        }

        return toolbarItem
    }

    func toolbarWillAddItem(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let item = userInfo["item"] as? NSToolbarItem
        if let item = item, item.itemIdentifier == .toggleSidebar {
            item.action = #selector(toggleSidebar)
        }
    }

    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        switch item.itemIdentifier {
        case .addStory:
            return false // Implement addStory button validation
        default:
            return true
        }
    }

    func customToolbarButtonItem(
        itemIdentifier: String,
        label: String,
        paletteLabel: String,
        toolTip: String,
        iconImageName: String,
        action: Selector) -> NSToolbarItem {

        let toolbarItem = CustomToolbarItem(itemIdentifier: NSToolbarItem.Identifier(rawValue: itemIdentifier))

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
    static let addStory = NSToolbarItem.Identifier(rawValue: "AddStory")
}

class CustomToolbarItem: NSToolbarItem {

    override func validate() {
        if let control = view as? NSControl, let action = action,
           let validator = NSApp.target(forAction: action, to: target, from: self) {
            switch validator {
            case let validator as NSUserInterfaceValidations:
                control.isEnabled = validator.validateUserInterfaceItem(self)
            case let validator as NSToolbarItemValidation:
                control.isEnabled = validator.validateToolbarItem(self)
            default:
                super.validate()
            }
        } else {
            super.validate()
        }
    }
}
