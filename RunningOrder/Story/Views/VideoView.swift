//
//  VideoView.swift
//  RunningOrder
//
//  Created by Clément Nonn on 19/02/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers
import AVFoundation
import AVKit

struct VideoView: View {
    @Binding var storyInformation: StoryInformation

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
        videoView
            .animation(.none)
            .border(Color.green, width: isVideoDropTargeted ? 4 : 0)
            .animation(.default)
            .onDrop(of: [.fileURL], isTargeted: $isVideoDropTargeted, perform: { itemProviders in
                guard let item = itemProviders.first else { return false }

                item.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { data, error in
                    if let data = data,
                       let string = String(data: data, encoding: .utf8),
                       let url = URL(string: string),
                       let fileType = UTType(filenameExtension: url.pathExtension),
                       fileType.conforms(to: .movie) {
                        storyInformation.videoUrl = url
                    } else if let error = error {
                        Logger.error.log(error)
                    } else {
                        Logger.debug.log("file not conforming to needs")
                    }
                }
                return true
            })
            .padding()
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
