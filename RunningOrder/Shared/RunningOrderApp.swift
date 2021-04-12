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
                }
        }
        .commands {
            CommandMenu("Espace de travail") {
                Button("Nouveau") {
                    appStateManager.currentState = .spaceCreation
                }

                Divider()

                if case .spaceSelected(let currentSpace) = appStateManager.currentState {
                    Button("Supprimer") {
                        spaceManager.delete(space: currentSpace)
                    }

                    if spaceManager.availableSpaces.count > 1 {
                        Picker("Changer d'espace", selection: selectedSpace) {
                            ForEach(spaceManager.availableSpaces, id: \.id) { space in
                                Text(space.name)
                                    .tag(space)
                            }
                        }
                    }

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
            }
            ToolbarCommands()
            SidebarCommands()
        }
    }
}
