//
//  MovieService.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 20.02.2026.
//

import Foundation

nonisolated protocol MovieServiceProtocol: Sendable {
    func trending(page: Int) async throws -> PagedResponse<Movie>
    func popular(page: Int) async throws -> PagedResponse<Movie>
    func topRated(page: Int) async throws -> PagedResponse<Movie>
    func search(query: String, page: Int) async throws -> PagedResponse<Movie>
    func similar(movieID: Int, page: Int) async throws -> PagedResponse<Movie>
    func videos(movieID: Int) async throws -> [Video]
}

nonisolated final class MovieService: MovieServiceProtocol, @unchecked Sendable {
    private let network: NetworkServiceProtocol
    private let cache: CacheProtocol
    private let logger: AppLogger
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(network: NetworkServiceProtocol, cache: CacheProtocol, logger: AppLogger) {
        self.network = network
        self.cache = cache
        self.logger = logger
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    private func cached<T: Codable & Sendable>(_ key: String, fetch: () async throws -> T) async throws -> T {
        if let data = await cache.value(forKey: key),
           let decoded = try? decoder.decode(T.self, from: data) {
            return decoded
        }
        do {
            let value = try await fetch()
            if let data = try? encoder.encode(value) {
                await cache.setValue(data, forKey: key)
            }
            return value
        } catch {
            if let data = await cache.value(forKey: key),
               let decoded = try? decoder.decode(T.self, from: data) {
                logger.warning("Returning stale cache for \(key)")
                return decoded
            }
            throw error
        }
    }

    func trending(page: Int) async throws -> PagedResponse<Movie> {
        try await cached("trending_\(page)") {
            try await network.get(.trending(page: page), as: PagedResponse<Movie>.self)
        }
    }

    func popular(page: Int) async throws -> PagedResponse<Movie> {
        try await cached("popular_\(page)") {
            try await network.get(.popular(page: page), as: PagedResponse<Movie>.self)
        }
    }

    func topRated(page: Int) async throws -> PagedResponse<Movie> {
        try await cached("toprated_\(page)") {
            try await network.get(.topRated(page: page), as: PagedResponse<Movie>.self)
        }
    }

    func search(query: String, page: Int) async throws -> PagedResponse<Movie> {
        try await network.get(.search(query: query, page: page), as: PagedResponse<Movie>.self)
    }

    func similar(movieID: Int, page: Int) async throws -> PagedResponse<Movie> {
        try await cached("similar_\(movieID)_\(page)") {
            try await network.get(.similar(movieID: movieID, page: page), as: PagedResponse<Movie>.self)
        }
    }

    func videos(movieID: Int) async throws -> [Video] {
        let response: VideoResponse = try await cached("videos_\(movieID)") {
            try await network.get(.videos(movieID: movieID), as: VideoResponse.self)
        }
        return response.results
    }
}
