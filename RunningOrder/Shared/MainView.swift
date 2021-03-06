//
//  MainView.swift
//  RunningOrder
//
//  Created by Clément Nonn on 23/06/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

extension MainView {
    private struct InternalView: View {
        @EnvironmentObject var spaceManager: SpaceManager
        @ObservedObject var logic: Logic

        init(logic: Logic) {
            self.logic = logic
        }

        @ViewBuilder var body: some View {
            switch spaceManager.state {
            case .loading:
                ProgressIndicator()
                    .padding()
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .center
                    )
            case .error(let error):
                Text("error : \(error)" as String)
                    .padding()

            case .noSpace:
                WelcomeView(space: logic.createdSpaceBinding)
                    .frame(
                        minWidth: 300,
                        maxWidth: 500,
                        minHeight: 200,
                        maxHeight: 200,
                        alignment: .leading
                    )

            case .spaceFound(let space):
                NavigationView {
                    SprintList(space: space)
                        .listStyle(SidebarListStyle())
                        .frame(minWidth: 160)

                    Text("Select a Sprint")
                        .frame(minWidth: 100, maxWidth: 400)
                        .toolbar {
                            ToolbarItems.sidebarItem
                            ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
                                Button(action: {}) {
                                    Image(systemName: "square.and.pencil")
                                }
                                .disabled(true)
                            }
                        }

                    Text("Select a Story")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .toolbar {
                            ToolbarItem {
                                Spacer()
                            }

                            ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
                                SearchBarView().frame(width: 300)
                            }
                            ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
                                Button(action: {}) {
                                    Image(systemName: "trash")
                                }
                                .disabled(true)
                            }
                        }
                }
                .frame(
                    minWidth: 800,
                    maxWidth: .infinity,
                    minHeight: 400,
                    maxHeight: .infinity,
                    alignment: .leading
                )
            }
        }
    }
}

struct MainView: View {
    @EnvironmentObject var spaceManager: SpaceManager

    var body: some View {
        InternalView(logic: Logic(spaceManager: spaceManager))
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(SpaceManager.preview)
    }
}
