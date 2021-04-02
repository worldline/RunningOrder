//
//  Sprints_Previews.swift
//  RunningOrder
//
//  Created by Clément Nonn on 08/07/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import Foundation
import SwiftUI

extension Sprint {
    enum Previews {
        static let sprints = [
            Sprint(
                spaceId: UUID().uuidString,
                number: 1,
                name: "Sprint",
                colorIdentifier: "holiday blue",

                zoneId: CKRecordZone.ID()
            ),
            Sprint(
                spaceId: UUID().uuidString,
                number: 2,
                name: "Sprint",
                colorIdentifier: "elf green",
                zoneId: CKRecordZone.ID()
            )
        ]
    }
}
