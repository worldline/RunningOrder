//
//  AddButton.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 20/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct AddButton: View {

    let action: () -> Void
    var body: some View {
        Button(action: self.action) {
            HStack {
                Image(nsImage: NSImage(named: NSImage.addTemplateName)!)
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
                    .background(Color.blue) // TODO Replace with accent color 
                    .clipShape(Circle())
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AddButton_Previews: PreviewProvider {
    static var previews: some View {
        AddButton(action: {})
    }
}
