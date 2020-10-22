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

        let changesService = CloudKitChangesService(container: CloudKitContainer.shared)

        let spaceManager = SpaceManager(service: SpaceService(), dataPublisher: changesService.spaceChangesPublisher.eraseToAnyPublisher())
        let sprintManager = SprintManager(service: SprintService(), dataPublisher: changesService.sprintChangesPublisher.eraseToAnyPublisher())
        let storyManager = StoryManager(service: StoryService(), dataPublisher: changesService.storyChangesPublisher.eraseToAnyPublisher())
        let storyInformationManager = StoryInformationManager(service: StoryInformationService(), dataPublisher: changesService.storyInformationChangesPublisher.eraseToAnyPublisher())

        let toolbarManager = ToolbarManager(
            splitViewControllerOwner: self,
            toolBar: toolbar,
            spaceManager: spaceManager
        )

        changesService.fetchChanges()

        let view = MainView()
            .environmentObject(toolbarManager)
            .environmentObject(spaceManager)
            .environmentObject(sprintManager)
            .environmentObject(storyManager)
            .environmentObject(storyInformationManager)

        toolbar.delegate = toolbarManager

        (NSApplication.shared.delegate as? AppDelegate)?.spaceManager = spaceManager
        (NSApplication.shared.delegate as? AppDelegate)?.changesService = changesService

        window?.toolbar = toolbar
        window?.contentViewController = NSHostingController(rootView: view)
    }
}
