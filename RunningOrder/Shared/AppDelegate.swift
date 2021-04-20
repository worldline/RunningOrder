//
//  AppDelegate.swift
//  RunningOrder
//
//  Created by Clément Nonn on 23/06/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Cocoa
import CloudKit
import Combine
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {

    private var cancellables = Set<AnyCancellable>()

    let cloudkitContainer = CloudKitContainer.shared
    var spaceManager: SpaceManager?
    weak var changesService: CloudKitChangesService?
    var appStateManager: AppStateManager?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        registerForPushNotification()
    }

    func application(_ application: NSApplication, userDidAcceptCloudKitShareWith metadata: CKShare.Metadata) {
        spaceManager?.acceptShare(metadata: metadata)
            .sink(
                receiveFailure: { error in Logger.error.log(error) },
                receiveValue: { [weak self] space in
                    self?.cloudkitContainer.enableNotificationsIfNeeded(for: metadata.rootRecordID.zoneID)
                    self?.changesService?.fetchChanges(on: metadata.rootRecordID.zoneID)
                    self?.appStateManager?.currentState = .spaceSelected(space)
                }
            )
            .store(in: &cancellables)
    }

    func application(_ application: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger.error.log(error)
    }

    func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Logger.verbose.log("notifications token : \(deviceToken)")
    }

    private func registerForPushNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: []) { granted, error in
            if let error = error {
                Logger.error.log(error)
            } else {
                Logger.verbose.log("notifications grant status : \(granted)")
            }
        }
        NSApplication.shared.registerForRemoteNotifications()
    }

    func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String: Any]) {
        Logger.debug.log("notif : \(userInfo)")
        guard let scope = cloudkitContainer.databaseScopeForNotification(userInfo) else { return }

        changesService?.fetchDatabaseChanges(in: scope)
    }
}
