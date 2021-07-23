//
//  EpicTextfield.swift
//  RunningOrder
//
//  Created by Clément Nonn on 15/07/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI

struct EpicTextField: View {
    let spaceId: Space.ID
    @Binding var epic: String
    // Workaround : The isFocused as a published var inside the Logic doesn't work, and I need it inside the logic and inside the internal view
    @State private var isFocused = false

    @EnvironmentObject var storyManager: StoryManager
    @EnvironmentObject var sprintManager: SprintManager

    var body: some View {
        InternalView(
            logic: Logic(
                epic: _epic,
                spaceId: spaceId,
                isFocused: $isFocused,
                storyManager: storyManager,
                sprintManager: sprintManager
            ),
            isFocused: $isFocused
        )
    }
}

extension EpicTextField {
    private struct InternalView: View {
        @ObservedObject var logic: Logic
        @Binding var isFocused: Bool

        var body: some View {
            FocusableTextField(
                placeholder: NSLocalizedString("Story EPIC", comment: ""),
                value: $logic.epic,
                isFocused: $isFocused,
                onCommit: { }
            )
            .focusableTextFieldFormStyle(isFocused: isFocused)
            .popover(isPresented: logic.showEpicSuggestions, arrowEdge: .bottom) {
                VStack(alignment: .leading) {
                    ForEach(logic.epicList) { epic in
                        Button(action: {
                            logic.selectEpic(epic)
                        }, label: {
                            Text(epic)
                        })
                        .buttonStyle(PlainButtonStyle())
                        .focusable(false)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
    }
}
