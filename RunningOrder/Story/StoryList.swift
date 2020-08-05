//
//  StoryList.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

extension Story: Identifiable {
    var id: String { ticketReference }
}

struct StoryList: View {
    let header: String
    @Binding var stories: [Story]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(header)
                .font(.headline)
                .padding(5)
            List {

                ForEach(stories.indices, id: \.self) { index in
                    NavigationLink(
                        destination: StoryDetail(story: $stories[index]),
                        label: {
                            StoryRow(story: stories[index])
                    })
                }
            }
        }
        .frame(maxWidth: 200)

    }
}
struct StoryList_Previews: PreviewProvider {
    static var previews: some View {
        StoryList(header: "Sprint 66 - HelloBank", stories: .constant(Story.Previews.stories))
    }
}
