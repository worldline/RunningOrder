//
//  StoriesView.swift
//  RunningOrder
//
//  Created by Clément Nonn on 07/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct StoriesView: View {
    var body: some View {
        List {
            Section(header: Text("Stories")) {
                Text("HB- GMT - Initier un vir inter 1/3 (Ecran devise)")
            }
        }
    }
}

struct StoriesView_Previews: PreviewProvider {
    static var previews: some View {
        StoriesView()
    }
}
