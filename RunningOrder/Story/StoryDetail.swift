//
//  StoryDetail.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct StoryDetail: View {

    @EnvironmentObject var storyManager: StoryManager

    let storyIndex: Int

    var storyBinding: Binding<Story> {
        return $storyManager.stories[storyIndex]
    }

    @State private var selectedMode = DisplayMode.video

    var body: some View {
        VStack(alignment: .leading) {
            StoryDetailHeader(story: storyBinding.wrappedValue)
                .padding(.all, 10)
            Divider()
                .padding(.all, 10)

            HSplitView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Configuration")
                        .font(.subheadline)
                        .bold()
                        .padding(.horizontal, 10)

                    InlineEditableList(title: "Environments", values: storyBinding.configuration.environments)

                    InlineEditableList(title: "Mock", values: storyBinding.configuration.mocks)

                    InlineEditableList(title: "Feature flip", values: storyBinding.configuration.features)

                    InlineEditableList(title: "Indicators", values: storyBinding.configuration.indicators)

                    InlineEditableList(title: "Identifier", values: storyBinding.configuration.identifiers)

                    Text("Links")
                        .font(.subheadline)
                        .bold()
                        .padding(.horizontal, 10)

                    InlineEditableList(title: "Links", values: Binding<[String]>(
                                        get: { storyBinding.wrappedValue.links.map { $0.label } },
                        set: { values in
                            storyBinding.wrappedValue.links = values
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
        }.background(Color.white)
    }
}

private enum DisplayMode: LocalizedStringKey, CaseIterable {
    case video = "Video"
    case steps = "Steps"
}
struct StoryDetail_Previews: PreviewProvider {
    static var previews: some View {
        StoryDetail(storyIndex: 0)
            .environmentObject(SprintManager())
    }
}
