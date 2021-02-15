//
//  ConfigurationView.swift
//  RunningOrder
//
//  Created by Lucas Barbero on 25/08/2020.
//  Copyright © 2020 Worldline. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers
import AVFoundation
import AVKit

struct StepsView: View {
    @Binding var storyInformation: StoryInformation
    @State private var selectedMode = DisplayMode.video

    @State private var isVideoDropTargeted = false
    @State private var isFileImporterPresented = false

    var avPlayer: AVPlayer? {
        if let videoUrl = storyInformation.createSymbolicVideoUrlIfNeeded(with: .default) {
            return AVPlayer(playerItem: AVPlayerItem(asset: AVAsset(url: videoUrl)))
        } else {
            return nil
        }
    }

    var body: some View {
        ScrollView {
            VStack {
                Picker("", selection: $selectedMode) {
                    ForEach(DisplayMode.allCases, id: \.self) { choice in
                        Text(choice.rawValue)
                    }
                }
                .padding()
                .pickerStyle(SegmentedPickerStyle())

                switch selectedMode {
                case .steps:
                    InlineEditableList(title: "Steps", placeholder: "A step to follow", values: self.$storyInformation.steps)

                case .video:
                    videoView
                        .animation(.none)
                        .border(Color.red, width: isVideoDropTargeted ? 2 : 0)
                        .animation(.default)
                        .onDrop(of: [.quickTimeMovie], isTargeted: $isVideoDropTargeted, perform: { itemProviders in
                            guard let item = itemProviders.first else { return false }

                            return true
                        })
                        .padding()
                }
                Spacer()
            }
        }
        .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.movie]) { result in
            switch result {
            case .success(let url):
                storyInformation.videoUrl = url
            case .failure(let error):
                Logger.error.log(error)
            }
        }
    }

    @ViewBuilder var videoView: some View {
        if let avPlayer = avPlayer {
            VideoPlayer(player: avPlayer)
                .frame(height: 600)
                .overlay(
                    RoundButton(image: Image(systemName: "trash"), color: .red) {
                        storyInformation.videoUrl = nil
                    }
                    .frame(width: 25, height: 25)
                    .padding(),
                    alignment: .topTrailing
                )
        } else {
            Rectangle()
                .frame(height: 600)
                .foregroundColor(.black)
                .overlay(
                    RoundButton(
                        image: Image(systemName: "tray.and.arrow.down"),
                        color: .gray,
                        action: { isFileImporterPresented = true }
                    )
                    .frame(width: 100, height: 100)
                    .padding(),
                    alignment: .center
                )
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
