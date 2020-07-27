//
//  RoundButton`.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 24/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct RoundButton: View {

    let imageName: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: self.action) {
            Image(nsImage: NSImage(named: imageName)!)
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
        RoundButton(imageName: NSImage.shareTemplateName, color: Color.green, action: {})
            .frame(width: 40, height: 40)
    }
}
