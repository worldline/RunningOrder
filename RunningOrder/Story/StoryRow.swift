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
            Tag(story.epic, color: Color("holiday blue"))
                .font(.system(size: 10))
            Spacer()
            Text(story.ticketReference)
                .foregroundColor(.gray)
                .font(.system(size: 10))
        }
        .padding(.all, 5)
    }
}

struct StoryRow_Previews: PreviewProvider {
    static var previews: some View {
        StoryRow(story: Story.Previews.stories[0])
    }
}
