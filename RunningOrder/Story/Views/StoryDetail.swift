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

    @EnvironmentObject var storyInformationManager: StoryInformationManager
    @EnvironmentObject var storyManager: StoryManager

    var informationBinding: Binding<StoryInformation> { storyInformationManager.informations(for: story.id) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            StoryDetailHeader(story: story)
                .padding(10)
            Divider()
                .padding(10)
            HSplitView {
                ConfigurationView(storyInformation: informationBinding)
                StepsView(storyInformation: informationBinding)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .toolbar {
            ToolbarItemGroup {
                Text(story.name)
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()
            }

            ToolbarItems.deleteStory(storyManager: storyManager, story: story)
        }
        .onAppear { storyManager.getUser(creatorOf: story) }
    }
}

struct StoryDetail_Previews: PreviewProvider {
    static var previews: some View {
        StoryDetail(story: Story.Previews.stories[0])
            .environmentObject(StoryInformationManager.preview)
            .environmentObject(StoryManager.preview)
            .environmentObject(SpaceManager.preview)
    }
}
