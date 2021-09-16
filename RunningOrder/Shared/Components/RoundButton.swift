//
//  RoundButton`.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 24/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

/// A simple colored round button with an image in it 
struct RoundButton: View {

    let image: Image
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: self.action) {
            GeometryReader(content: { geometry in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(geometry.size.width * 0.2)
                    .background(color)
                    .clipShape(Circle())
            })
        }
        .foregroundColor(.white)
        .buttonStyle(PlainButtonStyle())
    }
}

struct RoundButton_Previews: PreviewProvider {
    static var previews: some View {
        RoundButton(image: Image(nsImageName: NSImage.refreshTemplateName), color: Color.green, action: {})

        RoundButton(image: Image(systemName: "trash"), color: Color.green, action: {})
        RoundButton(image: Image(systemName: "trash"), color: Color.green, action: {})
            .frame(width: 40, height: 40)
        RoundButton(image: Image(systemName: "trash"), color: Color.green, action: {})
            .frame(width: 25, height: 25)
    }
}
