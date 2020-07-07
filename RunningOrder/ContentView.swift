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
            List {
                Section(header: Text("Active Sprints")) {
                    Text("Hello, World!")
                }

                Section(header: Text("Old Sprints")) {
                    Text("Hello, World!")
                }
            }.listStyle(SidebarListStyle())

            HStack {
                List {
                    Section(header: Text("Stories")) {
                        Text("Hello, World!")
                    }
                }.frame(minWidth: 100,  maxWidth: 200)

                Text("toto")
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, idealHeight: 100, maxHeight: .infinity, alignment: .leading)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
