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
    @State private var selectedMode = DisplayMode.video

    init(storyInformation: Binding<StoryInformation>) {
        _storyInformation = storyInformation
        _selectedMode = State(initialValue: storyInformation.wrappedValue.steps.isEmpty ? .video : .steps)
    }

    var body: some View {
        ScrollView {
            VStack {
                Picker("Steps Mode", selection: $selectedMode) {
                    ForEach(DisplayMode.allCases, id: \.self) { choice in
                        Text(choice.rawValue)
                    }
                }
                .padding()
                .labelsHidden()
                .pickerStyle(SegmentedPickerStyle())

                switch selectedMode {
                case .steps:
                    InlineEditableList(title: "Steps", placeholder: "A step to follow", values: self.$storyInformation.steps)

                case .video:
                    VideoView(storyInformation: $storyInformation)
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
        StepsView(storyInformation: .constant(StoryInformation(storyId: "", zoneId: CKRecordZone.ID())))
    }
}
