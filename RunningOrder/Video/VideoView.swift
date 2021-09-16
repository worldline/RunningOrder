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

extension VideoView.AlertConfiguration: Identifiable {
    var id: String {
        switch self {
        case .videoConfirmation(let video):
            return video.id
        case .error(.fileAlreadyExist):
            return "fileAlreadyExist"
        case .error(.internalError(let error)):
            return "\(error)"
        }
    }
}

struct VideoView: View {
    enum AlertConfiguration {
        case videoConfirmation(Video)
        case error(VideoError)
    }

    let storyId: Story.ID
    let zoneId: CloudKit.CKRecordZone.ID

    @EnvironmentObject var videoManager: VideoManager

    @State private var isVideoDropTargeted = false
    @State private var isFileImporterPresented = false
    @State private var isFileExporterPresented = false
    @State private var alertConfiguration: AlertConfiguration?

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
                                VStack {
                                    RoundButton(image: Image(systemName: "trash"), color: .red) {
                                        videoManager.delete(video: videoBinding.wrappedValue)

                                    }
                                    .frame(width: 35, height: 35)

                                    RoundButton(image: Image(systemName: "icloud.and.arrow.down"), color: .blue) {
                                        // Download
                                        do {
                                            try videoBinding.wrappedValue.save()
                                        } catch VideoError.fileAlreadyExist {
                                            alertConfiguration = .videoConfirmation(videoBinding.wrappedValue)
                                        } catch {
                                            Logger.debug.log("error at saving : \(error)")
                                            alertConfiguration = .error(.internalError(error))
                                        }
                                    }
                                    .frame(width: 35, height: 35)
                                }
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
                            Text("Broken")
                                .foregroundColor(.white),
                            alignment: .center
                        )
                        .overlay(
                            RoundButton(image: Image(systemName: "trash"), color: .red) {
                                videoManager.delete(video: videoBinding.wrappedValue)
                            }
                            .frame(width: 25, height: 25)
                            .padding(.trailing, 8)
                            .padding([.trailing, .top]),
                            alignment: .topTrailing
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
                        Text("Add a video")
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
        .alert(item: $alertConfiguration, content: { configuration in
            switch configuration {
            case .videoConfirmation(let video):
                return Alert(
                    title: Text("Warning"),
                    message: Text("A file already exists at this url \"\(video.downloadUrl().path)\", do you want to override it ?"),
                    primaryButton: .destructive(
                        Text("Yes"),
                        action: {
                            do {
                                try video.save()
                            } catch {
                                Logger.debug.log("Error at saving : \(error)")
                                self.alertConfiguration = .error(.internalError(error))
                            }
                        }
                    ),
                    secondaryButton: .cancel()
                )
            case .error(let error):
                return Alert(
                    title: Text("Error"),
                    message: Text("An error occurred : \(error.localizedDescription)")
                )
            }
        })
    }
}
