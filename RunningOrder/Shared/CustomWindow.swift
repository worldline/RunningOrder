//
//  CustomWindow.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Cocoa
import SwiftUI

final class AppWindowController: NSWindowController, SplitViewControllerOwner {

    // Computed property needed to facilitate toolbar's sidebar management
    var splitViewController: NSSplitViewController? {
            (window?.contentView?.subviews.first?.subviews.first?.subviews.first as? NSSplitView)?.delegate as? NSSplitViewController
        }

    override func windowDidLoad() {
        super.windowDidLoad()

        let toolbar = NSToolbar()

        let spaceManager = SpaceManager(service: SpaceService())
        let toolbarManager = ToolbarManager(
            splitViewControllerOwner: self,
            toolBar: toolbar,
            spaceManager: spaceManager
        )
        let changeService = CloudKitChangesService(container: CloudKitContainer.shared)

        let sprintManager = SprintManager(service: SprintService(), dataPublisher: changeService.sprintChangesPublisher.eraseToAnyPublisher())
        let storyManager = StoryManager(service: StoryService(), dataPublisher: changeService.storyChangesPublisher.eraseToAnyPublisher())
        let storyInformationManager = StoryInformationManager(service: StoryInformationService(), dataPublisher: changeService.storyInformationChangesPublisher.eraseToAnyPublisher())

        changeService.fetchChanges()

        let view = MainView()
            .environmentObject(toolbarManager)
            .environmentObject(spaceManager)
            .environmentObject(sprintManager)
            .environmentObject(storyManager)
            .environmentObject(storyInformationManager)

        toolbar.delegate = toolbarManager

        (NSApplication.shared.delegate as? AppDelegate)?.spaceManager = spaceManager
        (NSApplication.shared.delegate as? AppDelegate)?.changesService = changeService

        window?.toolbar = toolbar
        window?.contentViewController = NSHostingController(rootView: view)
    }
}
