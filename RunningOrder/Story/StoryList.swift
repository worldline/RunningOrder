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
    @Binding var stories: [Story]

    var body: some View {
        List {
            Section(header: Text("Stories")) {
                ForEach(stories) { story in
                    VStack(alignment: .leading) {
                        Text(story.ticketReference)
                        Text(story.name)
                    }
                }
            }
        }
    }
}

struct StoryList_Previews: PreviewProvider {
    static var previews: some View {
        StoryList(stories: .constant(Story.Previews.stories))
    }
}
