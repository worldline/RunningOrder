//
//  StoryDetail.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct StoryDetail: View {
    var sprintIndex: Int
    var storyIndex: Int

    @EnvironmentObject var sprintManager: SprintManager

    var story: Story {
        return sprintManager.sprints[sprintIndex].stories[storyIndex]
    }

    var storyBinding: Binding<Story> {
        return sprintManager.mutableStory(sprintIndex: sprintIndex, storyIndex: storyIndex)
    }

    private let displayMode = ["Vidéo", "Etapes"]

    @State private var selectedMode = "Vidéo"

    var body: some View {
        VStack(alignment: .leading) {
            StoryDetailHeader(story: story)
                .padding(.all, 10)
            Divider()
                .padding(.all, 10)

            HSplitView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Configuration")
                        .font(.subheadline)
                        .bold()
                        .padding(.horizontal, 6)

                    InlineEditableList(title: "Environments", placeholder: "", values: storyBinding.configuration.environments)

                    InlineEditableList(title: "Mock", placeholder: "", values: storyBinding.configuration.mocks)

                    InlineEditableList(title: "Feature flip", placeholder: "", values: storyBinding.configuration.features)

                    InlineEditableList(title: "Indicators", placeholder: "", values: storyBinding.configuration.indicators)

                    InlineEditableList(title: "Identifier", placeholder: "", values: storyBinding.configuration.identifiers)

                    Text("Link")
                        .font(.subheadline)
                        .bold()
                        .padding(.horizontal, 6)

                    InlineEditableList(title: "Specification", placeholder: "", values: storyBinding.link.specifications)

                    InlineEditableList(title: "Zeplin", placeholder: "", values: storyBinding.link.zeplins)

                    Spacer()
                }
                .padding(.all, 5)

                VStack {
                    Picker("", selection: $selectedMode) {
                        ForEach(displayMode, id: \.self) { choice in
                            Text(choice)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    switch selectedMode {
                    case "Vidéo":
                        Text("Vidéo")
                    case "Etapes":
                        Text("Etapes")
                    default:
                        EmptyView()
                    }

                    Spacer()
                }
            }
            Spacer()
        }.background(Color.white)

    }
}

struct StoryDetail_Previews: PreviewProvider {
    static var previews: some View {
        StoryDetail(sprintIndex: 0, storyIndex: 0)
    }
}
