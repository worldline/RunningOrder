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
            SprintList()
                .listStyle(SidebarListStyle())
                .frame(minWidth: 160)

            Text("Select a Sprint")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
        }
        .frame(
            minWidth: 800,
            maxWidth: .infinity,
            minHeight: 400,
            maxHeight: .infinity,
            alignment: .leading
        )
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
