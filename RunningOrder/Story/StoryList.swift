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
     let stories: [Story]

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Stories")) {
                    ForEach(stories) { story in
                        NavigationLink(
                            destination: StoryDetail(story: story),
                            label: {
                                Text(story.name)
                            })
                    }
                }
            }
            .frame(minWidth: 100, maxWidth: 200, maxHeight: .infinity)

            Text("Select a Story")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct StoryList_Previews: PreviewProvider {
    static var previews: some View {
        StoryList(stories: Story.Previews.stories)
    }
}
