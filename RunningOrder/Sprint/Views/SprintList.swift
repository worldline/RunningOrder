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

        var body: some View {
            List {
                Section(header: Text("Active Sprints")) {
                    ForEach(sprintManager.sprints, id: \.self) { sprint in
                        NavigationLink(
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
                        .contextMenu {
                            Button(
                                action: { logic.deleteSprint(sprint) },
                                label: { Text("Delete Sprint") }
                            )
                        }
                    }
                }
                Section(header: Text("Old Sprints")) {
                    EmptyView()
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
            .padding(.all, 20.0)
            .buttonStyle(PlainButtonStyle()), alignment: .bottom)
            .sheet(isPresented: $logic.isNewSprintModalPresented) {
                NewSprintView(spaceId: space.id, createdSprint: self.logic.createdSprintBinding)
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
        SprintList(space: Space(name: "toto"))
            .environmentObject(SprintManager.preview)
            .frame(width: 250)
    }
}
