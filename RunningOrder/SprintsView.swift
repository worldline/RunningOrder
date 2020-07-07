//
//  SprintsView.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct SprintsView: View {
    var body: some View {
        List {
            Section(header: Text("Active Sprints")) {
                Text("Sprint 94")
            }

            Section(header: Text("Old Sprints")) {
                Text("Sprint 93")
            }
        }
    }
}

struct SprintsView_Previews: PreviewProvider {
    static var previews: some View {
        SprintsView()
    }
}
