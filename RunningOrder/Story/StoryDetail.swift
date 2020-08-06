//
//  StoryDetail.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct StoryDetail: View {
    @Binding var story: Story

    var body: some View {
        VStack {
            Text(story.ticketReference)
            Text(story.name)
            Text(story.environment)
            Button {
                self.story.environment = "Autre chose"
            } label: {
                Text("test")
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct StoryDetail_Previews: PreviewProvider {
    static var previews: some View {
        StoryDetail(story: .constant(Story.Previews.stories[0]))
    }
}
