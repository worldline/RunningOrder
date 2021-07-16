//
//  StepsView.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 25/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct ConfigurationView: View {
    @Binding var storyInformation: StoryInformation

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("Configuration")
                    .font(.title2)
                    .padding(.leading, 12)

                InlineEditableList(title: "Environments", values: $storyInformation.configuration.environments)

                InlineEditableList(title: "Mock", values: $storyInformation.configuration.mocks)

                InlineEditableList(title: "Feature Flip", values: $storyInformation.configuration.features)

                InlineEditableList(title: "Indicators", values: $storyInformation.configuration.indicators)

                InlineEditableList(title: "Identifier", values: $storyInformation.configuration.identifiers)

                InlineEditableLinkList(title: "Links", values: $storyInformation.links)

                Text("Comment")
                    .font(.title2)
                    .padding(.leading, 12)

                ZStack(alignment: Alignment.topLeading) {
                    TextEditor(text: $storyInformation.comment)
                        .font(.body)

                    Text("Your comment here")
                        .foregroundColor(Color.init(NSColor.secondaryLabelColor))
                        .padding(.horizontal, 4)
                        .allowsHitTesting(false)
                        .opacity(storyInformation.comment.isEmpty ? 1 : 0)
                }

                Spacer()
            }
            .padding(.horizontal, 10)
        }
    }
}

struct StepsView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationView(storyInformation: .constant(StoryInformation(storyId: "", zoneId: CKRecordZone.ID())))
    }
}
