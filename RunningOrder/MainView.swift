//
//  MainView.swift
//  RunningOrder
//
//  Created by Clément Nonn on 23/06/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            SprintsView()
                .listStyle(SidebarListStyle())

            HSplitView {
                StoriesView()
                    .listStyle(PlainListStyle())
                    .frame(minWidth: 100, maxWidth: 400, maxHeight: .infinity)

                StoryDetailView().frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )
            }
        }
        .frame(
            maxWidth: .infinity,
            idealHeight: 100,
            maxHeight: .infinity,
            alignment: .leading
        )
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
