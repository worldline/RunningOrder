//
//  StoriesView.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

extension Story: Identifiable {
    var id: String { ticketReference }
}

struct StoriesView: View {
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

struct StoriesView_Previews: PreviewProvider {
    static var previews: some View {
        StoriesView(stories: .constant([]))
    }
}
