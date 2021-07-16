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
        @State private var toBeDeletedSprint: Sprint?

        var body: some View {
            VStack {
                List {
                    Section(header: Text("Active Sprints")) {
                        ForEach(logic.activeSprints(for: space.id), id: \.self) { sprint in
                            SprintRow(sprintToDelete: $toBeDeletedSprint, sprint: sprint)
                        }
                    }
                    Section(header: Text("Closed Sprints")) {
                        ForEach(logic.closedSprints(for: space.id), id: \.self) { sprint in
                            SprintRow(sprintToDelete: $toBeDeletedSprint, sprint: sprint)
                        }
                    }
                }

                footer
            }
            .sheet(isPresented: $logic.isNewSprintModalPresented) {
                NewSprintView(space: space, createdSprint: self.logic.createdSprintBinding)
            }
            .alert(item: $toBeDeletedSprint) { sprint in
                Alert(
                    title: Text("Delete the sprint \"\(sprint.name) - \(sprint.number)\" ?"),
                    message: Text("You can't undo this action."),
                    primaryButton: .destructive(Text("Yes"), action: { logic.deleteSprint(sprint) }),
                    secondaryButton: .cancel()
                )
            }
        }

        @ViewBuilder var footer: some View {
            HStack {
                Button(action: self.logic.showNewSprintModal) {
                    HStack { // sprintListFooter
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
                .buttonStyle(PlainButtonStyle())

                Spacer()

                AppStateIndicator()
            }
            .padding([.horizontal, .bottom])
            .padding(.top, 4)
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
            .listStyle(SidebarListStyle())
            .environmentObject(SprintManager.preview)
            .frame(width: 250)
    }
}
