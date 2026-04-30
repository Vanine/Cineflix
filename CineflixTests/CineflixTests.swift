//
//  CineflixTests.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 04.03.2026.
//

import Testing
import Foundation
@testable import Cineflix

@MainActor
struct HomeViewModelTests {
    private func makeLogger() -> AppLogger {
        AppLogger(subsystem: "test", category: "test")
    }

    @Test func loadsAllSectionsOnAppear() async throws {
        let mock = MockMovieService()
        mock.trendingResult = .success(PagedResponse(page: 1, results: [MockData.movie(id: 1)], totalPages: 5, totalResults: 5))
        mock.popularResult = .success(PagedResponse(page: 1, results: [MockData.movie(id: 2)], totalPages: 5, totalResults: 5))
        mock.topRatedResult = .success(PagedResponse(page: 1, results: [MockData.movie(id: 3)], totalPages: 5, totalResults: 5))

        let vm = HomeViewModel(service: mock, logger: makeLogger())
        vm.onAppear()
        try await Task.sleep(for: .milliseconds(100))

        #expect(vm.trending.count == 1)
        #expect(vm.popular.count == 1)
        #expect(vm.topRated.count == 1)
        #expect(vm.state == .loaded)
    }

    @Test func setsErrorStateOnFailure() async throws {
        let mock = MockMovieService()
        mock.trendingResult = .failure(APIError.transport("offline"))
        let vm = HomeViewModel(service: mock, logger: makeLogger())
        vm.onAppear()
        try await Task.sleep(for: .milliseconds(100))

        if case .error = vm.state {} else {
            Issue.record("Expected error state")
        }
    }
}

@MainActor
struct SearchViewModelTests {
    private func makeLogger() -> AppLogger {
        AppLogger(subsystem: "test", category: "test")
    }

    @Test func debouncesQueryAndDeduplicatesCalls() async throws {
        let mock = MockMovieService()
        mock.searchResult = .success(PagedResponse(page: 1, results: [MockData.movie()], totalPages: 1, totalResults: 1))
        let vm = SearchViewModel(service: mock, logger: makeLogger())

        vm.query = "b"
        vm.query = "ba"
        vm.query = "bat"
        try await Task.sleep(for: .milliseconds(500))

        #expect(mock.searchCalls.count == 1)
        #expect(mock.searchCalls.first?.0 == "bat")
        #expect(vm.results.count == 1)
    }

    @Test func clearsResultsWhenQueryEmpty() async throws {
        let mock = MockMovieService()
        mock.searchResult = .success(PagedResponse(page: 1, results: [MockData.movie()], totalPages: 1, totalResults: 1))
        let vm = SearchViewModel(service: mock, logger: makeLogger())
        vm.query = "batman"
        try await Task.sleep(for: .milliseconds(400))
        #expect(!vm.results.isEmpty)

        vm.query = ""
        try await Task.sleep(for: .milliseconds(400))
        #expect(vm.results.isEmpty)
        #expect(vm.state == .idle)
    }
}
