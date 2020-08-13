//
//  StoryDetail.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct StoryDetail: View {

    let story: Story

    @State private var selectedMode = DisplayMode.video
    @EnvironmentObject var storyInformationManager: StoryInformationManager

    init(story: Story) {
        self.story = story
    }

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
                        .padding(.horizontal, 10)

                    InlineEditableList(title: "Environments", values: $storyInformationManager.storyInformation.configuration.environments)

                    InlineEditableList(title: "Mock", values: $storyInformationManager.storyInformation.configuration.mocks)

                    InlineEditableList(title: "Feature flip", values: $storyInformationManager.storyInformation.configuration.features)

                    InlineEditableList(title: "Indicators", values: $storyInformationManager.storyInformation.configuration.indicators)

                    InlineEditableList(title: "Identifier", values: $storyInformationManager.storyInformation.configuration.identifiers)

                    Text("Links")
                        .font(.subheadline)
                        .bold()
                        .padding(.horizontal, 10)

                    InlineEditableList(title: "Links", values: Binding<[String]>(
                                        get: { self.storyInformationManager.storyInformation.links.map { $0.label } },
                        set: { values in
                            self.storyInformationManager.storyInformation.links = values
                                .map { Link(value: $0)}
                        })
                    )

                    Spacer()
                }
                .padding(.all, 5)

                VStack {
                    Picker("", selection: $selectedMode) {
                        ForEach(DisplayMode.allCases, id: \.self) { choice in
                            Text(choice.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Text(selectedMode.rawValue)

                    Spacer()
                }
            }
        }
        .background(Color.white)
        .onAppear {
            storyInformationManager.fetchInformation(storyId: story.id)
        }
    }
}

private enum DisplayMode: LocalizedStringKey, CaseIterable {
    case video = "Video"
    case steps = "Steps"
}
struct StoryDetail_Previews: PreviewProvider {
    static var previews: some View {
        StoryDetail(story: Story.Previews.stories[0])
            .environmentObject(StoryInformationManager())
    }
}
