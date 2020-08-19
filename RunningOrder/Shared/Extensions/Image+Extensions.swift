//
//  Image+Extensions.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 05/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

extension Image {
    init(nsImageName: NSImage.Name) {
        self.init(nsImage: NSImage(named: nsImageName)!)
    }
}
