//
//  WelcomeView.swift
//  RunningOrder
//
//  Created by Clément Nonn on 22/09/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appStateManager: AppStateManager
    @EnvironmentObject var spaceManager: SpaceManager

    @Binding var space: Space?
    @State private var newSpaceName = ""
    @State private var hasErrorOnField = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Welcome").font(.largeTitle)
            Text("You don't have yet your space, or joined a shared space")

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    TextField("My Space Name", text: $newSpaceName)
                        .overlay(Rectangle()
                                    .strokeBorder(Color.red, lineWidth: 2.0, antialiased: true)
                                    .opacity(hasErrorOnField ? 1 : 0)
                                    .animation(.default)
                        )

                    Button("Create") {
                        withAnimation {
                            self.hasErrorOnField = newSpaceName.isEmpty
                        }

                        guard !hasErrorOnField else { return }

                        space = Space(name: newSpaceName, zoneId: CloudKitContainer.shared.ownedZoneId)
                    }
                }

                if hasErrorOnField {
                    Text("Please enter a name for your workspace")
                        .foregroundColor(.red)
                        .animation(.easeInOut)
                }
            }

            Divider()
                .overlay(Text("Or")
                            .padding(.horizontal, 10)
                            .background(Color(NSColor.controlBackgroundColor)))
            Text("Just open a link from your team to access this space")

            if let backSpace = spaceManager.availableSpaces.last {
                Divider()

                HStack {
                    Spacer()

                    Button("Go back to previous space") {
                        appStateManager.currentState = .spaceSelected(backSpace)
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(space: .constant(nil))
            .preferredColorScheme(.dark)

        WelcomeView(space: .constant(nil))
            .preferredColorScheme(.light)
    }
}
