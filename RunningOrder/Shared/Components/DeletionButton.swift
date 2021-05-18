//
//  DeletionButton.swift
//  RunningOrder
//
//  Created by Clément Nonn on 18/05/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI

struct DeletionButton: View {
    @State private var showConfirmation = false
    let alertTitle: LocalizedStringKey
    let alertDescription: LocalizedStringKey
    let deletionBlock: () -> Void

    var body: some View {
        Button(action: { showConfirmation = true }) {
            Image(systemName: "trash")
        }
        .alert(isPresented: $showConfirmation, content: {
            Alert(
                title: Text(alertTitle),
                message: Text(alertDescription),
                primaryButton: .destructive(Text("Yes"), action: { deletionBlock() }),
                secondaryButton: .cancel()
            )
        })
    }
}

struct DeletionButton_Previews: PreviewProvider {
    static var previews: some View {
        DeletionButton(
            alertTitle: "Alert Title",
            alertDescription: "Alert Description",
            deletionBlock: { }
        )
    }
}
