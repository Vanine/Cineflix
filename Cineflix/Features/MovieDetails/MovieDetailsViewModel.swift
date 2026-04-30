//
//  MovieDetailsViewModel.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 01.03.2026.
//

import Foundation
import Combine
import SwiftData

@MainActor
final class MovieDetailsViewModel: ObservableObject {
    @Published private(set) var movie: Movie
    @Published private(set) var similar: [Movie] = []
    @Published private(set) var trailerKey: String?
    @Published private(set) var hasFetchedVideos: Bool = false
    @Published var isLoadingTrailer: Bool = false
    @Published var trailerError: String?

    private let service: MovieServiceProtocol
    private let recentlyViewed: RecentlyViewedServiceProtocol
    private let logger: AppLogger
    private var loadTask: Task<Void, Never>?

    init(movie: Movie,
         service: MovieServiceProtocol,
         recentlyViewed: RecentlyViewedServiceProtocol,
         logger: AppLogger) {
        self.movie = movie
        self.service = service
        self.recentlyViewed = recentlyViewed
        self.logger = logger
    }

    func onAppear() {
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }
            await self.recentlyViewed.record(self.movie)
            async let similarTask: () = self.loadSimilar()
            async let videosTask: () = self.loadVideos()
            _ = await (similarTask, videosTask)
        }
    }

    private func loadSimilar() async {
        do {
            let response = try await service.similar(movieID: movie.id, page: 1)
            self.similar = response.results
        } catch {
            logger.warning("Similar failed: \(error)")
        }
    }

    private func loadVideos() async {
        do {
            let videos = try await service.videos(movieID: movie.id)
            let trailer = videos.first(where: { $0.isYouTubeTrailer && ($0.official ?? false) })
                ?? videos.first(where: { $0.isYouTubeTrailer })
            self.trailerKey = trailer?.key
            self.hasFetchedVideos = true
        } catch {
            logger.warning("Videos failed: \(error)")
            self.hasFetchedVideos = true
        }
    }

    func cancel() {
        loadTask?.cancel()
    }
}
