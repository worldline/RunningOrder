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

    var informationBinding: Binding<StoryInformation> { storyInformationManager.informations(for: story.id) }

    var body: some View {
        VStack(alignment: .leading) {
            StoryDetailHeader(story: story)
                .padding(.all, 10)
            Divider()
                .padding(.all, 10)

            if storyInformationManager.storyInformations[story.id] != nil {
                HSplitView {

                    ConfigurationView(storyInformation: informationBinding)

                    StepsView(storyInformation: informationBinding)
                }
            } else {
                ProgressIndicator()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.white)
        .onAppear {
            self.storyInformationManager.loadData(for: story.id)
        }
    }
}

#if DEBUG
struct StoryDetail_Previews: PreviewProvider {
    static var previews: some View {
        StoryDetail(story: Story.Previews.stories[0])
            .environmentObject(StoryInformationManager(service: StoryInformationService()))
    }
}
#endif
