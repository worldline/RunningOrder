//
//  SprintList.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

extension Sprint: Identifiable {
    var id: String { self.name }
}

struct SprintList: View {
    @State private var showNewSprintModal = false
    @EnvironmentObject var toolbarManager: ToolbarManager
    @EnvironmentObject var sprintManager: SprintManager

    var body: some View {
        VStack(alignment: .leading) {
            List {
                Section(header: Text("Active Sprints")) {
                    ForEach(sprintManager.sprints.indices, id: \.self) { index in
                        NavigationLink(
                            destination: StoryList(sprintIndex: index )
                                .environmentObject(toolbarManager),
                            label: {
                                HStack {
                                    SprintNumber(number: sprintManager.sprints[index].number, colorIdentifier: sprintManager.sprints[index].colorIdentifier)
                                    Text(sprintManager.sprints[index].name)
                                }
                            }
                        )
                    }
                }
                Section(header: Text("Old Sprints")) {
                    EmptyView()
                }
            }

            Button(action: { self.showNewSprintModal.toggle() }) {
                HStack {
                    Image(nsImageName: NSImage.addTemplateName)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                    Text("New Sprint")
                        .foregroundColor(Color.accentColor)
                }
            }
            .padding(.all, 8.0)
            .buttonStyle(PlainButtonStyle())
        }.sheet(isPresented: $showNewSprintModal) {
            NewSprintView(createdSprint: self.$sprintManager.sprints.appendedElement)
        }
    }
}

struct SprintList_Previews: PreviewProvider {
    static var previews: some View {
        SprintList()
            .listStyle(SidebarListStyle())
            .frame(width: 250)
    }
}
