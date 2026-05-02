//
//  SearchViewModel.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 28.02.2026.
//

import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var sortOption: SearchSortOption = .relevance
    @Published private(set) var results: [Movie] = []
    @Published private(set) var state: LoadState = .idle

    var sortedResults: [Movie] {
        switch sortOption {
        case .relevance:
            return results
        case .ratingDesc:
            return results.sorted { ($0.voteAverage ?? -1) > ($1.voteAverage ?? -1) }
        case .releaseDateDesc:
            return results.sorted { ($0.releaseDate ?? "") > ($1.releaseDate ?? "") }
        case .releaseDateAsc:
            return results.sorted {
                let a = $0.releaseDate ?? ""
                let b = $1.releaseDate ?? ""
                if a.isEmpty { return false }
                if b.isEmpty { return true }
                return a < b
            }
        }
    }

    private var page = 1
    private var totalPages = 1
    private var loadingMore = false
    private var currentQuery = ""
    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    private let service: MovieServiceProtocol
    private let logger: AppLogger

    init(service: MovieServiceProtocol, logger: AppLogger) {
        self.service = service
        self.logger = logger
        bindQuery()
    }

    private func bindQuery() {
        $query
            .removeDuplicates()
            .debounce(for: .milliseconds(AppConstants.Search.debounceMilliseconds), scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                self?.performSearch(query: value)
            }
            .store(in: &cancellables)
    }

    private func performSearch(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        searchTask?.cancel()

        guard !trimmed.isEmpty else {
            results = []
            state = .idle
            currentQuery = ""
            return
        }

        if trimmed == currentQuery, !results.isEmpty { return }

        currentQuery = trimmed
        page = 1
        totalPages = 1
        state = .loading

        searchTask = Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await self.service.search(query: trimmed, page: 1)
                if Task.isCancelled { return }
                self.results = response.results
                self.totalPages = response.totalPages ?? 1
                self.state = response.results.isEmpty ? .loaded : .loaded
            } catch is CancellationError {
                return
            } catch {
                if Task.isCancelled { return }
                self.logger.error("Search failed: \(error)")
                self.state = .error((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
            }
        }
    }

    func loadMoreIfNeeded(current movie: Movie) {
        guard results.last?.id == movie.id else { return }
        guard !loadingMore, page < totalPages, !currentQuery.isEmpty else { return }
        loadingMore = true
        Task { [weak self] in
            guard let self else { return }
            defer { self.loadingMore = false }
            do {
                let next = self.page + 1
                let response = try await self.service.search(query: self.currentQuery, page: next)
                let existing = Set(self.results.map(\.id))
                let added = response.results.filter { !existing.contains($0.id) }
                self.results.append(contentsOf: added)
                self.page = next
                self.totalPages = response.totalPages ?? next
            } catch {
                self.logger.warning("Search pagination failed: \(error)")
            }
        }
    }

    func cancel() {
        searchTask?.cancel()
    }
}
