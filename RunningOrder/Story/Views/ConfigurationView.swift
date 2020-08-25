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
            VStack(alignment: .leading, spacing: 0) {
                Text("Configuration")
                    .font(.subheadline)
                    .bold()
                    .padding(.horizontal, 10)

                InlineEditableList(title: "Environments", values: $storyInformation.configuration.environments)

                InlineEditableList(title: "Mock", values: $storyInformation.configuration.mocks)

                InlineEditableList(title: "Feature flip", values: $storyInformation.configuration.features)

                InlineEditableList(title: "Indicators", values: $storyInformation.configuration.indicators)

                InlineEditableList(title: "Identifier", values: $storyInformation.configuration.identifiers)

                Text("Links")
                    .font(.subheadline)
                    .bold()
                    .padding(.horizontal, 10)

                InlineEditableList(
                    title: "Links",
                    values: Binding<[String]>(
                        get: { self.storyInformation.links.map { $0.label } },
                        set: { values in self.storyInformation.links = values.map { Link(value: $0) } }
                    )
                )

                Spacer()
            }
            .padding(.all, 5)
        }
    }
}

struct StepsView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationView(storyInformation: .constant(StoryInformation(storyId: "")))
    }
}
