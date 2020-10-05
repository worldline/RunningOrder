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
import CloudKit
import Combine

protocol SplitViewControllerOwner {
    var splitViewController: NSSplitViewController? { get }
}

// toolbar guidance : https://developer.apple.com/documentation/appkit/touch_bar/integrating_a_toolbar_and_touch_bar_into_your_app
/// The class responsible of managing the toolbar and its respective toolbaritem
class ToolbarManager: NSObject, ObservableObject {

    let splitViewControllerOwner: SplitViewControllerOwner
    var isASprintSelected = false

    @Published var isAddStoryButtonClicked = false

    let spaceManager: SpaceManager
    private var share: CKShare?

    var cancellables = Set<AnyCancellable>()

    init(splitViewControllerOwner: SplitViewControllerOwner, toolBar: NSToolbar, spaceManager: SpaceManager) {
        self.splitViewControllerOwner = splitViewControllerOwner
        self.spaceManager = spaceManager

        // update the status of cloudSharing directly when status of space is updated
        spaceManager.$state
            .receive(on: DispatchQueue.main)
            .sink { _ in toolBar.validateVisibleItems() }
            .store(in: &cancellables)
    }
}

// MARK: NSToolbarDelegate

extension ToolbarManager: NSToolbarDelegate {
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {

        switch itemIdentifier {
        case .addStory:
            return customToolbarButtonItem(
                itemIdentifier: itemIdentifier.rawValue,
                label: NSLocalizedString("Add a story", comment: ""),
                paletteLabel: NSLocalizedString("Add a story", comment: ""),
                toolTip: NSLocalizedString("Add a story", comment: ""),
                iconImageName: NSImage.addTemplateName,
                action: #selector(addStory)
            )

        case .sidebarToggle :
            return customToolbarButtonItem(
                itemIdentifier: itemIdentifier.rawValue,
                label: NSLocalizedString("Sidebar", comment: ""),
                paletteLabel: NSLocalizedString("Sidebar", comment: ""),
                toolTip: NSLocalizedString("Show the Sidebar", comment: ""),
                iconImageName: NSImage.touchBarSidebarTemplateName,
                action: #selector(toggleSidebar(_:))
            )

        default:
            return nil
        }
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
        guard let userInfo = notification.userInfo,
              let item = userInfo["item"] as? NSToolbarItem,
              item.itemIdentifier == .cloudSharing else { return }

        item.target = self
    }
}

// MARK: NSToolbarItemValidation

extension ToolbarManager: NSToolbarItemValidation, NSCloudSharingValidation {
    func cloudShare(for item: NSValidatedUserInterfaceItem) -> CKShare? {
        return share
    }

    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        switch item.itemIdentifier {
        case .addStory:
            return isASprintSelected
        case .cloudSharing:
            return self.spaceManager.space != nil
        default:
            return true
        }
    }
}

extension ToolbarManager {

    // MARK: Custom toolbar item

    @objc func toggleSidebar(_ sender: Any) {
        splitViewControllerOwner.splitViewController?.toggleSidebar(sender)
    }

    @objc func addStory() {
        isAddStoryButtonClicked.toggle()
    }

    @objc func performCloudSharing(_ sender: Any) {
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

    /// Useful func to create a formated custom toolbar button with an image in it
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

extension ToolbarManager: NSCloudSharingServiceDelegate {}

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
