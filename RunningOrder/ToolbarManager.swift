//
//  ToolbarManager.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 27/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import Cocoa
import SwiftUI

class ToolbarManager: NSObject, ObservableObject, NSToolbarDelegate, NSToolbarItemValidation {

    let sidebarController: SplitViewControllerAccessor
    var isASprintSelected = false

    @Published var isAddStoryButtonClicked = false

    init(splitViewController: SplitViewControllerAccessor) {
        sidebarController = splitViewController
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {

        var toolbarItem = NSToolbarItem()

        switch itemIdentifier {

        case .addStory:
            toolbarItem = customToolbarButtonItem(itemIdentifier: itemIdentifier.rawValue,
                                                  label: NSLocalizedString("Add a story", comment: ""),
                                                  paletteLabel: NSLocalizedString("Add a story", comment: ""),
                                                  toolTip: NSLocalizedString("Add a story", comment: ""),
                                                  iconImageName: NSImage.addTemplateName,
                                                  action: #selector(addStory))

        case .sidebarToggle :
            toolbarItem = customToolbarButtonItem(itemIdentifier: itemIdentifier.rawValue,
                                                  label: NSLocalizedString("Sidebar", comment: ""),
                                                  paletteLabel: NSLocalizedString("Sidebar", comment: ""),
                                                  toolTip: NSLocalizedString("Show the Sidebar", comment: ""),
                                                  iconImageName: NSImage.touchBarSidebarTemplateName,
                                                  action: #selector(toggleSidebar(_:)))
        default:
            return nil
        }

        return toolbarItem
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .sidebarToggle,
            .space,
            .addStory,
            .flexibleSpace,
            .cloudSharing
        ]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            .sidebarToggle,
            .addStory,
            .flexibleSpace,
            .cloudSharing
        ]
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
            return isASprintSelected
        default:
            return true
        }
    }

    @objc func toggleSidebar(_ sender: Any) {
        sidebarController.splitViewController?.toggleSidebar(sender)
    }

    @objc func addStory() {
        isAddStoryButtonClicked.toggle()
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
}

extension NSToolbarItem.Identifier {
    static let addStory = NSToolbarItem.Identifier(rawValue: "AddStory")
    static let sidebarToggle = NSToolbarItem.Identifier(rawValue: "SidebarToggle")
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
