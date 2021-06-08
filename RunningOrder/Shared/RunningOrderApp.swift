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

    @StateObject var userManager = UserManager(
        userService: UserService()
    )

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

    var _enabledLogs = Logger.enabledLogsBinding

    var enabledLogs: [Logger] { _enabledLogs.wrappedValue }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(spaceManager)
                .environmentObject(sprintManager)
                .environmentObject(storyManager)
                .environmentObject(storyInformationManager)
                .environmentObject(searchManager)
                .environmentObject(appStateManager)
                .environmentObject(userManager)
                .onAppear {
                    appDelegate.changesService = changesService
                    appDelegate.spaceManager = spaceManager

                    appStateManager.fetchFirstSpace(in: spaceManager, withProgress: changesService.refreshAll())
                    Logger.disabledLevels = [.verbose]
                }
                .onReceive(appStateManager.$currentState) { state in
                    guard case .spaceSelected(let space) = state else {
                        return
                    }
                    userManager.fetchUser(for: space)
                }
        }
        .commands {
            CommandGroup(before: CommandGroupPlacement.appSettings) {
                Button("Report a bug") {
                    openURL(bugReportURL)
                }
            }
            CommandMenu("Workspace") {
                Button("New") {
                    appStateManager.currentState = .spaceCreation
                }
                .keyboardShortcut("n", modifiers: [.command, .shift, .option])

                Divider()

                if case .spaceSelected(let currentSpace) = appStateManager.currentState {
                    Button("Delete") {
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
                        Picker("Switch Workspace", selection: selectedSpace) {
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
                        "Share",
                        action: CloudSharingHandler(spaceManager: spaceManager, space: currentSpace).performCloudSharing
                    )
                    .keyboardShortcut("s", modifiers: [.command, .shift])

                    Divider()
                    Text("Current workspace : \(currentSpace.name)")
                } else {
                    Text("No current workspace")
                }
            }

            CommandMenu("DEBUG") {
                Button("Delete Subscription") {
                    CloudKitContainer.shared.removeSubscriptions()
                }

                Button("test") {
                    CloudKitContainer.shared.test()
                }

                Menu("Logs") {
                    ForEach(Logger.allCases, id: \.title) { logger in
                        HStack {
                            Button(logger.title) {
                                if let index = enabledLogs.firstIndex(of: logger) {
                                    _enabledLogs.wrappedValue.remove(at: index)
                                } else {
                                    _enabledLogs.wrappedValue.append(logger)
                                }
                            }
                        }
                    }
                }
            }
            ToolbarCommands()
            SidebarCommands()
        }
    }
}

extension Logger {
    static var enabledLogsBinding: Binding<[Logger]> {
        Binding {
            Self.allCases.filter { !Self.disabledLevels.contains($0) }
        } set: { newValue in
            Self.disabledLevels = Self.allCases.filter { !newValue.contains($0) }
            Logger.debug.log("new disabledLevels : \(disabledLevels)")
        }
    }
}
