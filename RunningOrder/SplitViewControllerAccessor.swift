//
//  File.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 05/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import Cocoa

class SplitViewControllerAccessor: SplitViewControllerProtocol {

    let windowController: AppWindowController

    var splitViewController: NSSplitViewController? {
        (windowController.window?.contentView?.subviews.first?.subviews.first?.subviews.first as? NSSplitView)?.delegate as? NSSplitViewController
    }

    init(windowController: AppWindowController) {
        self.windowController = windowController
    }
}
