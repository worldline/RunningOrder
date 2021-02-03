//
//  ToolbarItems.swift
//  RunningOrder
//
//  Created by Clément Nonn on 02/02/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI

enum ToolbarItems {
    static let sidebarItem = ToolbarItem(placement: ToolbarItemPlacement.navigation) {
        Button {
            NSApp.keyWindow?
                .firstResponder?
                .tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        } label: {
            Image(systemName: "sidebar.left")
        }
    }

    static func cloudSharingItem(for cloudSharingManager: CloudSharingHandler) -> some ToolbarContent {
        ToolbarItem(placement: ToolbarItemPlacement.confirmationAction) {
            Button(action: cloudSharingManager.performCloudSharing, label: {
                Image(systemName: "person.crop.circle.badge.plus")
            })
        }
    }
}
