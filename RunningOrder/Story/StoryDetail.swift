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

    var informationBinding: Binding<StoryInformation> { storyInformationManager.informations(for: story.id) }

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

                    InlineEditableList(title: "Environments", values: informationBinding.configuration.environments)

                    InlineEditableList(title: "Mock", values: informationBinding.configuration.mocks)

                    InlineEditableList(title: "Feature flip", values: informationBinding.configuration.features)

                    InlineEditableList(title: "Indicators", values: informationBinding.configuration.indicators)

                    InlineEditableList(title: "Identifier", values: informationBinding.configuration.identifiers)

                    Text("Links")
                        .font(.subheadline)
                        .bold()
                        .padding(.horizontal, 10)

                    InlineEditableList(
                        title: "Links",
                        values: Binding<[String]>(
                            get: { self.informationBinding.links.wrappedValue.map { $0.label } },
                            set: { values in self.informationBinding.links.wrappedValue = values.map { Link(value: $0) } }
                        )
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

                    switch selectedMode {
                    case .steps:
                        InlineEditableList(title: "Steps", placeholder: "A step to follow", values: self.binding.steps)

                    case .video:
                        Text(selectedMode.rawValue)
                    }

                    Spacer()
                }
            }
        }
        .background(Color.white)
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
