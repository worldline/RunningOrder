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
        HStack {
            VStack(alignment: .leading) {
                Text(story.name).font(.headline)
                    .padding()
                HStack {
                    Tag(story.ticketReference, color: Color.gray)
                    Tag(story.epic, color: Color("holiday blue"))
                }
                .padding(.horizontal)
                Divider()

                Text("Configuration").font(.headline)

                Spacer()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

    }
}

struct StoryDetail_Previews: PreviewProvider {
    static var previews: some View {
        StoryDetail(story: .constant(Story.Previews.stories[0]))
    }
}
