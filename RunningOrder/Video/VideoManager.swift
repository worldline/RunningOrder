//
//  VideoManager.swift
//  RunningOrder
//
//  Created by Clément Nonn on 13/07/2021.
//  Copyright © 2021 Worldline. All rights reserved.
//

import Foundation
import Combine
import CloudKit
import SwiftUI

/// The class responsible of managing the Story data, this is the only source of truth
final class VideoManager: ObservableObject {
    @Published var videos: [Video] = []
    @Stored(fileName: "videos.json", directory: .applicationSupportDirectory) private var storedVideos: [Video]?

    var cancellables: Set<AnyCancellable> = []
    private let service: VideoService
    private let debouncingUpdateVideo = PassthroughSubject<Video, Never>()

    init(service: VideoService, dataPublisher: AnyPublisher<ChangeInformation, Never>) {
        self.service = service

        if let storedVideos = storedVideos {
            videos = storedVideos
        }

        dataPublisher.sink(receiveValue: { [weak self] informations in
            self?.updateData(with: informations.toUpdate)
            self?.deleteData(recordIds: informations.toDelete)
        }).store(in: &cancellables)

        debouncingUpdateVideo
            .debounce(for: 4, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] video in
                self?.update(video: video)
            })
            .store(in: &cancellables)

        $videos
            .throttle(for: 5, scheduler: DispatchQueue.main, latest: true)
            .map { $0 as [Video]? }
            .assign(to: \.storedVideos, on: self)
            .store(in: &cancellables)
    }

    private func updateData(with updatedRecords: [CKRecord]) {
        do {
            let updatedVideos = try updatedRecords
                .sorted(by: { ($0.creationDate ?? Date()) < ($1.creationDate ?? Date()) })
                .map(Video.init(from:))

            var currentVideos = self.videos
            for video in updatedVideos {
                if let index = currentVideos.firstIndex(where: { $0.id == video.id }) {
                    currentVideos[index] = video
                } else {
                    Logger.warning.log("story with id \(video.id) not found, so appending it to existing video list")
                    currentVideos.append(video)
                }
            }
            DispatchQueue.main.async {
                self.videos = currentVideos
            }
        } catch {
            Logger.error.log(error)
        }
    }

    private func deleteData(recordIds: [CKRecord.ID]) {
        for recordId in recordIds {
            if let index = videos.firstIndex(where: { $0.id == recordId.recordName }) {
                DispatchQueue.main.async {
                    self.videos.remove(at: index)
                }
            } else {
                Logger.warning.log("video not found when deleting \(recordId.recordName)")
            }
        }
    }

    func videos(for story: Story.ID) -> [Binding<Video>] {
        self.videos
            .filter { $0.storyId == story }
            .map { video in
                Binding {
                    video
                } set: { [weak self] newValue in
                    self?.debouncingUpdateVideo.send(newValue)
                }
            }
    }

    func update(video: Video) {
        service.save(video: video)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveFailure: { error in
                    Logger.error.log(error)
                },
                receiveValue: { [weak self] video in
                    guard let index = self?.videos.firstIndex(where: { $0.id == video.id }) else {
                        Logger.error.log("couldn't find index of story in stored stories")
                        return
                    }
                    self?.videos[index] = video
                }
            )
            .store(in: &cancellables)
    }

    func add(video: Video) {
        service.save(video: video)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveFailure: { error in
                    Logger.error.log(error)
                },
                receiveValue: { [weak self] video in
                    self?.videos.append(video)
                }
            )
            .store(in: &cancellables)

    }

    func delete(video: Video) {
        service.delete(video: video)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    Logger.error.log(error) // TODO: error Handling
                case .finished:
                    try? video.deleteFile()
                    guard let index = self?.videos.firstIndex(where: { $0.id == video.id }) else {
                        Logger.error.log("couldn't find index of story in stored stories")
                        return
                    }
                    self?.videos.remove(at: index)
                }
            })
            .store(in: &cancellables)
    }
}
