//
//  RoundButton`.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 24/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct RoundButton: View {

    let image: Image
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: self.action) {
            image
                .resizable()
                .padding(5)
                .foregroundColor(.white)
        }
        .background(color)
        .buttonStyle(PlainButtonStyle())
        .clipShape(Circle())
    }
}

struct RoundButton_Previews: PreviewProvider {
    static var previews: some View {
        RoundButton(image: Image(nsImageName: NSImage.refreshTemplateName), color: Color.green, action: {})
            .frame(width: 40, height: 40)
    }
}
