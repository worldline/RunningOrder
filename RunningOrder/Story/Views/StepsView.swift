//
//  ConfigurationView.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 25/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct StepsView: View {
    @Binding var storyInformation: StoryInformation
    @State private var selectedMode = DisplayMode.steps

    var body: some View {
        ScrollView {
            VStack {
                Picker("", selection: $selectedMode) {
                    ForEach(DisplayMode.allCases, id: \.self) { choice in
                        Text(choice.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                switch selectedMode {
                case .steps:
                    InlineEditableList(title: "Steps", placeholder: "A step to follow", values: self.$storyInformation.steps)

                case .video:
                    Text(selectedMode.rawValue)
                }
                Spacer()
            }
        }
    }
}

private enum DisplayMode: LocalizedStringKey, CaseIterable {
    case video = "Video"
    case steps = "Steps"
}

struct ConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        StepsView(storyInformation: .constant(StoryInformation(storyId: "")))
    }
}
