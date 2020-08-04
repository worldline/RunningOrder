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
        VStack(alignment: .leading) {
            HStack {
                Text(story.epic)
                    .foregroundColor(Color.white)
                    .font(.system(size: 10))
                    .padding(.horizontal, 4)
                    .background(Color("holiday blue"))
                    .clipShape(RoundedRectangle(cornerRadius: 2))
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
        StoryRow(story: Story.Previews.stories[0])
    }
}
