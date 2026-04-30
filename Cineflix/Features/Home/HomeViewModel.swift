//
//  HomeViewModel.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 26.02.2026.
//

import Foundation
import SwiftUI
import Combine

enum LoadState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var trending: [Movie] = []
    @Published private(set) var popular: [Movie] = []
    @Published private(set) var topRated: [Movie] = []
    @Published private(set) var state: LoadState = .idle

    private var trendingPage = 1
    private var popularPage = 1
    private var topRatedPage = 1
    private var trendingTotal = Int.max
    private var popularTotal = Int.max
    private var topRatedTotal = Int.max

    private var loadingTrending = false
    private var loadingPopular = false
    private var loadingTopRated = false

    private let service: MovieServiceProtocol
    private let logger: AppLogger
    private var task: Task<Void, Never>?

    init(service: MovieServiceProtocol, logger: AppLogger) {
        self.service = service
        self.logger = logger
    }

    func onAppear() {
        guard state == .idle else { return }
        loadInitial()
    }

    func refresh() async {
        trendingPage = 1; popularPage = 1; topRatedPage = 1
        trendingTotal = .max; popularTotal = .max; topRatedTotal = .max
        await loadAll(reset: true)
    }

    private func loadInitial() {
        task?.cancel()
        task = Task { await loadAll(reset: true) }
    }

    private func loadAll(reset: Bool) async {
        state = .loading
        do {
            async let t = service.trending(page: 1)
            async let p = service.popular(page: 1)
            async let r = service.topRated(page: 1)
            let (tr, po, tp) = try await (t, p, r)
            self.trending = tr.results
            self.popular = po.results
            self.topRated = tp.results
            self.trendingTotal = tr.totalPages ?? 1
            self.popularTotal = po.totalPages ?? 1
            self.topRatedTotal = tp.totalPages ?? 1
            self.trendingPage = 1
            self.popularPage = 1
            self.topRatedPage = 1
            self.state = .loaded
        } catch is CancellationError {
            return
        } catch {
            logger.error("Home load failed: \(error)")
            self.state = .error((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
        }
    }

    func loadMoreTrendingIfNeeded(current movie: Movie) {
        guard trending.last?.id == movie.id else { return }
        guard !loadingTrending, trendingPage < trendingTotal else { return }
        loadingTrending = true
        Task { [weak self] in
            guard let self else { return }
            defer { self.loadingTrending = false }
            do {
                let next = self.trendingPage + 1
                let response = try await self.service.trending(page: next)
                let existing = Set(self.trending.map(\.id))
                let added = response.results.filter { !existing.contains($0.id) }
                self.trending.append(contentsOf: added)
                self.trendingPage = next
                self.trendingTotal = response.totalPages ?? next
            } catch {
                self.logger.warning("Trending pagination failed: \(error)")
            }
        }
    }

    func loadMorePopularIfNeeded(current movie: Movie) {
        guard popular.last?.id == movie.id else { return }
        guard !loadingPopular, popularPage < popularTotal else { return }
        loadingPopular = true
        Task { [weak self] in
            guard let self else { return }
            defer { self.loadingPopular = false }
            do {
                let next = self.popularPage + 1
                let response = try await self.service.popular(page: next)
                let existing = Set(self.popular.map(\.id))
                let added = response.results.filter { !existing.contains($0.id) }
                self.popular.append(contentsOf: added)
                self.popularPage = next
                self.popularTotal = response.totalPages ?? next
            } catch {
                self.logger.warning("Popular pagination failed: \(error)")
            }
        }
    }

    func loadMoreTopRatedIfNeeded(current movie: Movie) {
        guard topRated.last?.id == movie.id else { return }
        guard !loadingTopRated, topRatedPage < topRatedTotal else { return }
        loadingTopRated = true
        Task { [weak self] in
            guard let self else { return }
            defer { self.loadingTopRated = false }
            do {
                let next = self.topRatedPage + 1
                let response = try await self.service.topRated(page: next)
                let existing = Set(self.topRated.map(\.id))
                let added = response.results.filter { !existing.contains($0.id) }
                self.topRated.append(contentsOf: added)
                self.topRatedPage = next
                self.topRatedTotal = response.totalPages ?? next
            } catch {
                self.logger.warning("Top rated pagination failed: \(error)")
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
