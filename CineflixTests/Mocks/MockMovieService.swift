//
//  MockMovieService.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 04.03.2026.
//

import Foundation
@testable import Cineflix

nonisolated final class MockMovieService: MovieServiceProtocol, @unchecked Sendable {
    var trendingResult: Result<PagedResponse<Movie>, Error> = .success(PagedResponse(page: 1, results: [], totalPages: 1, totalResults: 0))
    var popularResult: Result<PagedResponse<Movie>, Error> = .success(PagedResponse(page: 1, results: [], totalPages: 1, totalResults: 0))
    var topRatedResult: Result<PagedResponse<Movie>, Error> = .success(PagedResponse(page: 1, results: [], totalPages: 1, totalResults: 0))
    var searchResult: Result<PagedResponse<Movie>, Error> = .success(PagedResponse(page: 1, results: [], totalPages: 1, totalResults: 0))
    var similarResult: Result<PagedResponse<Movie>, Error> = .success(PagedResponse(page: 1, results: [], totalPages: 1, totalResults: 0))
    var videosResult: Result<[Video], Error> = .success([])

    private(set) var searchCalls: [(String, Int)] = []
    private(set) var trendingCalls: [Int] = []

    func trending(page: Int) async throws -> PagedResponse<Movie> {
        trendingCalls.append(page)
        return try trendingResult.get()
    }
    func popular(page: Int) async throws -> PagedResponse<Movie> { try popularResult.get() }
    func topRated(page: Int) async throws -> PagedResponse<Movie> { try topRatedResult.get() }
    func search(query: String, page: Int) async throws -> PagedResponse<Movie> {
        searchCalls.append((query, page))
        return try searchResult.get()
    }
    func similar(movieID: Int, page: Int) async throws -> PagedResponse<Movie> { try similarResult.get() }
    func videos(movieID: Int) async throws -> [Video] { try videosResult.get() }
}

nonisolated enum MockData {
    static func movie(id: Int = 1, title: String = "Test") -> Movie {
        Movie(id: id, title: title, overview: "Overview", posterPath: "/p.jpg",
              backdropPath: "/b.jpg", voteAverage: 7.5, releaseDate: "2024-01-01")
    }
}
