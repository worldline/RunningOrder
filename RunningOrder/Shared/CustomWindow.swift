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

        let toolbarManager = ToolbarManager(splitViewControllerOwner: self)

        let toolbar = NSToolbar()
        toolbar.delegate = toolbarManager

        window?.toolbar = toolbar

        let view = MainView()
            .environmentObject(toolbarManager)
            .environmentObject(SprintManager(service: SprintService()))
            .environmentObject(StoryManager(service: StoryService()))
            .environmentObject(StoryInformationManager(service: StoryInformationService()))
        window?.contentViewController = NSHostingController(rootView: view)
    }
}
