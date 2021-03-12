//
//  StoryDetailHeader.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 10/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

extension StoryDetailHeader {
    struct InternalView: View {
        @Environment(\.epicColor) var epicColor
        let story: Story
        @ObservedObject var logic: Logic

        var body: some View {
            HStack {
                Tag(story.ticketReference, color: Color.gray)
                Tag(story.epic, color: epicColor)
                Spacer()
                if let userName = logic.userName {
                    Label(userName, systemImage: "person.circle.fill")
                        .font(Font.title2.bold())
                }
            }
            .onAppear {
                logic.fetchUsername(for: story)
            }
        }
    }
}

struct StoryDetailHeader: View {
    @EnvironmentObject var storyManager: StoryManager
    let story: Story

    var body: some View {
        InternalView(story: story, logic: Logic(storyManager: storyManager))
    }
}

struct StoryDetailHeader_Previews: PreviewProvider {
    static var previews: some View {
        StoryDetailHeader(story: Story.Previews.stories[0])
            .environmentObject(StoryManager.preview)
    }
}
