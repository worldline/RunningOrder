//
//  SuggestionRow.swift
//  RunningOrder
//
//  Created by Ghita Laoud on 26/03/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI

struct SuggestionRow: View {
    let imageName: String
    let suggestion: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: imageName)
            Text(suggestion)
        }
        .padding(5)
    }
}

struct SuggestionRow_Previews: PreviewProvider {
    static var previews: some View {
        SuggestionRow(imageName: "person.circle", suggestion: "FPL-11999")
    }
}
