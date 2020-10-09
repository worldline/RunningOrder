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

struct SprintList: View {
    @State private var showNewSprintModal = false
    @EnvironmentObject var sprintManager: SprintManager
    @EnvironmentObject var storyManager: StoryManager
    @EnvironmentObject var toolbarManager: ToolbarManager

    let space: Space

    private let disposeBag = DisposeBag()

    var createdSprintBinding: Binding<Sprint?> {
        return Binding<Sprint?>(
            get: { return nil },
            set: { newValue in
                if let sprint = newValue {
                    addSprint(sprint: sprint)
                }
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading) {
            List {
                Section(header: Text("Active Sprints")) {
                    ForEach(sprintManager.sprints, id: \.self) { sprint in
                        NavigationLink(
                            destination: StoryList(sprint: sprint)
                                .environmentObject(storyManager)
                                .environmentObject(toolbarManager),
                            label: {
                                HStack {
                                    SprintNumber(number: sprint.number, colorIdentifier: sprint.colorIdentifier)
                                    Text(sprint.name)
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
                        .font(.system(size: 12))
                }
            }
            .padding(.all, 20.0)
            .buttonStyle(PlainButtonStyle())
        }
        .sheet(isPresented: $showNewSprintModal) {
            NewSprintView(spaceId: space.id, createdSprint: self.createdSprintBinding)
        }
    }

    func addSprint(sprint: Sprint) {
        sprintManager.add(sprint: sprint)
            .ignoreOutput()
            .sink(receiveFailure: { failure in
                Logger.error.log(failure) // TODO error Handling
            })
            .store(in: &disposeBag.cancellables)
    }
}

struct SprintList_Previews: PreviewProvider {
    static var previews: some View {
        SprintList(space: Space(name: "toto"))
            .environmentObject(SprintManager(service: SprintService(), dataPublisher: changeInformationPreview))
            .frame(width: 250)
    }
}
