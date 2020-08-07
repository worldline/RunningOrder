//
//  StoryRow.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 28/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct StoryRow: View {

    var sprintIndex: Int
    var storyIndex: Int

    @EnvironmentObject var sprintManager: SprintManager

    var story: Story {
        return sprintManager.sprints[sprintIndex].stories[storyIndex]
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Tag(story.epic, color: Color("holiday blue"))
                    .font(.system(size: 10))
                Spacer()
                Text(story.ticketReference)
                    .foregroundColor(.gray)
                    .font(.system(size: 10))
            }
            Text(story.name)
        }
        .padding(.all, 5)
    }
}

struct StoryRow_Previews: PreviewProvider {
    static var previews: some View {
        StoryRow(sprintIndex: 0, storyIndex: 0)
    }
}
