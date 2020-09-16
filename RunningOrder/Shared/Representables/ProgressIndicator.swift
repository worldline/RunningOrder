//
//  ProgressIndicator.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 25/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct ProgressIndicator: NSViewRepresentable {

    func makeNSView(context: NSViewRepresentableContext<ProgressIndicator>) -> NSProgressIndicator {
        NSProgressIndicator()
    }

    func updateNSView(_ nsView: NSProgressIndicator, context: NSViewRepresentableContext<ProgressIndicator>) {
        nsView.style = .spinning
        nsView.startAnimation(true)
    }
}

struct ProgressIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ProgressIndicator()
    }
}
