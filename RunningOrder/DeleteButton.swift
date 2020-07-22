//
//  DeleteButton.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 21/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct DeleteButton: View {

    let action: () -> Void
    var body: some View {
        Button(action: self.action) {
            HStack {
                Image(nsImage: NSImage(named: NSImage.removeTemplateName)!)
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
                    .background(Color.red)
                    .clipShape(Circle())
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DeleteButton_Previews: PreviewProvider {
    static var previews: some View {
        DeleteButton(action: {})
    }
}
