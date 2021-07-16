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
    let storyId: Story.ID
    let zoneId: CloudKit.CKRecordZone.ID

    @EnvironmentObject var videoManager: VideoManager

    @State private var isVideoDropTargeted = false
    @State private var isFileImporterPresented = false

    var body: some View {
        videoListView
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
                        videoManager.add(
                            video: Video(
                                name: url.lastPathComponent,
                                url: url,
                                storyId: storyId,
                                zoneId: zoneId
                            )
                        )
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
                    videoManager.add(
                        video: Video(
                            name: url.lastPathComponent,
                            url: url,
                            storyId: storyId,
                            zoneId: zoneId
                        )
                    )
                case .failure(let error):
                    Logger.error.log(error)
                }
            }
    }

    @ViewBuilder var videoListView: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(videoManager.videos(for: storyId), id: \.wrappedValue.id) { videoBinding in
                if let avPlayer = videoBinding.wrappedValue.avPlayer {
                    VStack {
                        VideoPlayer(player: avPlayer)
                            .frame(height: 600)
                            .padding(.horizontal, 8)
                            .overlay(
                                RoundButton(image: Image(systemName: "trash"), color: .red) {
                                    videoManager.delete(video: videoBinding.wrappedValue)
                                }
                                .frame(width: 25, height: 25)
                                .padding(.trailing, 8)
                                .padding([.trailing, .top]),
                                alignment: .topTrailing
                            )

                        StyledFocusableTextField(
                            "",
                            value: videoBinding.name,
                            onCommit: {}
                        )
                    }
                } else {
                    Rectangle()
                        .frame(height: 600)
                        .foregroundColor(.black)
                        .overlay(
                            Text("Broken"),
                            alignment: .center
                        )
                }
            }

            HStack {
                Button {
                    isFileImporterPresented = true
                } label: {
                    HStack { // sprintListFooter
                        Image(nsImageName: NSImage.addTemplateName)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .background(Color.accentColor)
                            .clipShape(Circle())
                        Text("Ajouter une vidéo")
                            .foregroundColor(Color.accentColor)
                            .font(.system(size: 12))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 8)

                Spacer()
            }
        }
        .padding(.horizontal, 15)
    }
}
