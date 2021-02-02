//
//  StoryRow.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 28/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct StoryRow: View {

    let story: Story

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Tag(story.epic, color: Color(identifier: .holidayBlue))
                    .font(.caption2)

                Spacer()

                Text(story.ticketReference)
                    .foregroundColor(.secondary)
                    .font(.caption2)
            }
            Text(story.name)
        }
        .padding(5)
    }
}

struct StoryRow_Previews: PreviewProvider {
    static var previews: some View {
        StoryRow(story: Story.Previews.stories[0])
    }
}
