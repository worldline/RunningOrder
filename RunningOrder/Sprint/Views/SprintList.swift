//
//  SprintList.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI
import Combine

extension Sprint: Identifiable {}

extension SprintList {
    fileprivate struct InternalView: View {
        @EnvironmentObject var sprintManager: SprintManager
        @EnvironmentObject var storyManager: StoryManager
        @ObservedObject var logic: Logic
        let space: Space

        private func setupSprintDisplay(_ sprint: Sprint) -> some View {
            return NavigationLink(
                destination: StoryList(sprint: sprint),
                label: {
                    HStack {
                        SprintNumber(
                            number: sprint.number,
                            colorIdentifier: sprint.colorIdentifier
                        )
                        Text(sprint.name)
                    }
                }
            )
        }

        private func setupDeleteButton(_ sprint: Sprint) -> some View {
            return Button(
                action: { logic.deleteSprint(sprint) },
                label: {
                    Text("Delete Sprint")
                    .foregroundColor(.red)
                }
            )
        }

        var body: some View {
            List {
                Section(header: Text("Active Sprints")) {
                    ForEach(sprintManager.sprints(for: space.id), id: \.self) { sprint in
                        if !sprint.closed {
                            setupSprintDisplay(sprint)
                            .contextMenu {
                                Button(
                                    action: { logic.closeSprint(sprint) },
                                    label: { Text("Close Sprint") }
                                )
                                setupDeleteButton(sprint)
                            }
                        }
                    }
                }
                Section(header: Text("Closed Sprints")) {
                    ForEach(sprintManager.sprints(for: space.id), id: \.self) { sprint in
                        if sprint.closed {
                            setupSprintDisplay(sprint)
                            .contextMenu {
                                setupDeleteButton(sprint)
                            }
                        }
                    }
                }
            }
            .overlay(Button(action: self.logic.showNewSprintModal) {
                HStack {
                    Image(nsImageName: NSImage.addTemplateName)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                    Text("New Sprint")
                        .foregroundColor(Color.accentColor)
                        .font(.system(size: 12))
                }
            }
            .keyboardShortcut(KeyEquivalent("n"), modifiers: .command)
            .padding(.all, 20.0)
            .buttonStyle(PlainButtonStyle()), alignment: .bottom)
            .sheet(isPresented: $logic.isNewSprintModalPresented) {
                NewSprintView(space: space, createdSprint: self.logic.createdSprintBinding)
            }
        }
    }
}

struct SprintList: View {
    @EnvironmentObject var sprintManager: SprintManager
    let space: Space

    var body: some View {
        InternalView(logic: Logic(sprintManager: sprintManager), space: space)
    }
}

struct SprintList_Previews: PreviewProvider {
    static var previews: some View {
        SprintList(space: Space(name: "toto", zoneId: CKRecordZone.ID()))
            .environmentObject(SprintManager.preview)
            .frame(width: 250)
    }
}
