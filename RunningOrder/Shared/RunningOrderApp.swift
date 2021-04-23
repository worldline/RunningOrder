//
//  RunningOrderApp.swift
//  RunningOrder
//
//  Created by Clément Nonn on 02/02/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI
import Combine

let changesService = CloudKitChangesService(container: CloudKitContainer.shared)

@main
struct RunningOrderApp: App {
    // Not adapted to SwiftUI Lifecycle
    // swiftlint:disable:next weak_delegate
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @StateObject var searchManager = SearchManager()

    @StateObject var spaceManager = SpaceManager(
        service: SpaceService(),
        dataPublisher: changesService.spaceChangesPublisher.eraseToAnyPublisher()
    )

    @StateObject var sprintManager = SprintManager(
        service: SprintService(),
        dataPublisher: changesService.sprintChangesPublisher.eraseToAnyPublisher()
    )

    @StateObject var storyManager = StoryManager(
        service: StoryService(),
        userService: UserService(),
        dataPublisher: changesService.storyChangesPublisher.eraseToAnyPublisher()
    )

    @StateObject var storyInformationManager = StoryInformationManager(
        service: StoryInformationService(),
        dataPublisher: changesService.storyInformationChangesPublisher.eraseToAnyPublisher()
    )

    @StateObject var appStateManager = AppStateManager()

    let bugReportURL = URL(string: "https://github.com/worldline/RunningOrder/issues/new?assignees=&labels=bug&template=bug_report.md&title=%5BBUG%5D")!

    @Environment(\.openURL) var openURL

    let timerCancellable = Timer
        .publish(every: 180, on: .main, in: .default)
        .autoconnect()
        .print(in: .debug)
        .sink { _ in
            Logger.verbose.log("refreshing...")
            changesService.refreshAll()
        }

    /// **Warning** This binding can't be used without an active space selection
    var selectedSpace: Binding<Space> {
        Binding {
            if case .spaceSelected(let space) = appStateManager.currentState {
                return space
            } else {
                fatalError()
            }
        } set: { newSelection in
            appStateManager.currentState = .spaceSelected(newSelection)
        }
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(spaceManager)
                .environmentObject(sprintManager)
                .environmentObject(storyManager)
                .environmentObject(storyInformationManager)
                .environmentObject(searchManager)
                .environmentObject(appStateManager)
                .onAppear {
                    appDelegate.changesService = changesService
                    appDelegate.spaceManager = spaceManager
                    changesService.initialFetch()
                    appStateManager.fetchFirstSpace(in: spaceManager)
                    Logger.disabledLevels = [.verbose]
                }
        }
        .commands {
            CommandGroup(before: CommandGroupPlacement.appSettings) {
                Button("Report a bug") {
                    openURL(bugReportURL)
                }
            }
            CommandMenu("Espace de travail") {
                Button("Nouveau") {
                    appStateManager.currentState = .spaceCreation
                }
                .keyboardShortcut("n", modifiers: [.command, .shift, .option])

                Divider()

                if case .spaceSelected(let currentSpace) = appStateManager.currentState {
                    Button("Supprimer") {
                        spaceManager.delete(space: currentSpace)
                        var spacesLeft = spaceManager.availableSpaces
                        spacesLeft.removeAll(where: { currentSpace == $0 })
                        if let newSelection = spacesLeft.first {
                            appStateManager.currentState = .spaceSelected(newSelection)
                        } else {
                            appStateManager.currentState = .spaceCreation
                        }
                    }

                    if spaceManager.availableSpaces.count > 1 {
                        Picker("Changer d'espace", selection: selectedSpace) {
                            ForEach(spaceManager.availableSpaces, id: \.id) { space in
                                Text(space.name)
                                    .tag(space)
                            }
                        }
                    }

                    Button("Refresh") {
                        changesService.refreshAll()
                    }
                    .keyboardShortcut("r", modifiers: .command)

                    Button(
                        "Partager",
                        action: CloudSharingHandler(spaceManager: spaceManager, space: currentSpace).performCloudSharing
                    )
                    .keyboardShortcut("s", modifiers: [.command, .shift])

                    Divider()
                    Text("Espace actuel : \(currentSpace.name)")
                } else {
                    Text("Pas d'espace de travail courant")
                }
            }

            CommandMenu("DEBUG") {
                Button("Delete Subscription") {
                    CloudKitContainer.shared.removeSubscriptions()
                }

                Button("test") {
                    CloudKitContainer.shared.test()
                }
            }
            ToolbarCommands()
            SidebarCommands()
        }
    }
}
