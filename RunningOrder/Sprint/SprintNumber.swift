//
//  SwiftUIView.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 20/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct SprintNumber: View {
    let number: Int
    let colorIdentifier: String

    var body: some View {
        Text("\(number)")
            .foregroundColor(Color.white)
            .frame(width: 25, height: 12)
            .padding(.all, 2)
            .background(Color(colorIdentifier))
            .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SprintNumber(number: 454, colorIdentifier: "green1")
    }
}
