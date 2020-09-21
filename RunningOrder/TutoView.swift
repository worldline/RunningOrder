//
//  TutoView.swift
//  RunningOrder
//
//  Created by Clément Nonn on 22/09/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct TutoView: View {

    @Binding var space: Space?
    @State private var newSpaceName = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Welcome").font(.largeTitle)
            Text("You don't have yet your space, or joined a shared space")
            HStack {
                TextField("My Space Name", text: $newSpaceName)
                Button("Create") {
                    space = Space(name: newSpaceName)
                }
            }

            Divider()
                .overlay(Text("Or")
                            .padding(.horizontal, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                            .background(Color.white))
            Text("Just open a link from your team to access this space")
        }
        .padding()
        .background(Color.white)
    }
}

struct TutoView_Previews: PreviewProvider {
    static var previews: some View {
        TutoView(space: .constant(nil))
    }
}
