//
//  ConfigurationView.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 25/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI

struct StepsView: View {
    let storyId: Story.ID
    let zoneId: CloudKit.CKRecordZone.ID

    @Binding var steps: [String]
    @State private var selectedMode = DisplayMode.video

    init(steps: Binding<[String]>, storyId: Story.ID, zoneId: CloudKit.CKRecordZone.ID) {
        _steps = steps
        _selectedMode = State(initialValue: steps.wrappedValue.isEmpty ? .video : .steps)

        self.storyId = storyId
        self.zoneId = zoneId
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
                    InlineEditableList(
                        title: "Steps",
                        placeholder: "A step to follow",
                        values: self.$steps
                    )

                case .video:
                    VideoView(
                        storyId: storyId,
                        zoneId: zoneId
                    )
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
        StepsView(
            steps: .constant(["step 1", "step 2"]),
            storyId: "",
            zoneId: CloudKit.CKRecordZone.ID()
        )
    }
}
