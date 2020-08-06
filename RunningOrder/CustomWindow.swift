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
final class AppWindowController: NSWindowController, SplitViewControllerOwner {

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
            .environmentObject(SprintManager())

        window?.contentViewController = NSHostingController(rootView: view)
    }
}
