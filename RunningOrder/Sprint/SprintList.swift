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
    @State private var sprints: [Sprint] = []
    @State private var showNewSprintModal = false
    @EnvironmentObject var toolbarManager: ToolbarManager

    var body: some View {
        VStack(alignment: .leading) {
            List {
                Section(header: Text("Active Sprints")) {
                    ForEach(sprints, id: \.self) { sprint in
                        NavigationLink( // TODO construct/ pass the header in a different way ?
                            destination: StoryList(header: "Sprint \(sprint.number) - \(sprint.name)", stories: $sprints[sprints.firstIndex(of: sprint)!].stories) // Not proud of this line
                                .listStyle(PlainListStyle()),
                            label: {
                                HStack {
                                    SprintNumber(number: sprint.number, colorIdentifier: sprint.colorIdentifier)
                                    Text(sprint.name)
                                }
                            })
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
            NewSprintView(createdSprint: self.$sprints.appendedElement)
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
