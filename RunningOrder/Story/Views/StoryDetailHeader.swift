//
//  StoryDetailHeader.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 10/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct StoryDetailHeader: View {

    let story: Story

    var body: some View {
        VStack(alignment: .leading) {
            Text(story.name)
                .font(.headline)
                .fontWeight(.heavy)
                .padding(.bottom, 10)
            HStack {
                Tag(story.ticketReference, color: Color.gray)
                Tag(story.epic, color: Color(identifier: .holidayBlue))
            }
        }
    }
}

struct StoryDetailHeader_Previews: PreviewProvider {
    static var previews: some View {
        StoryDetailHeader(story: Story.Previews.stories[0])
    }
}
