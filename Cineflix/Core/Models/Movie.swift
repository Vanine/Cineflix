//
//  Movie.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 16.02.2026.
//

import Foundation

nonisolated struct Movie: Codable, Hashable, Identifiable, Sendable {
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double?
    let releaseDate: String?

    var posterURL: URL? { TMDBImage.poster(path: posterPath) }
    var backdropURL: URL? { TMDBImage.backdrop(path: backdropPath) }

    var ratingFormatted: String {
        guard let voteAverage else { return "—" }
        return String(format: "%.1f", voteAverage)
    }

    var year: String {
        guard let releaseDate, releaseDate.count >= 4 else { return "" }
        return String(releaseDate.prefix(4))
    }
}

nonisolated struct PagedResponse<T: Codable & Sendable>: Codable, Sendable {
    let page: Int
    let results: [T]
    let totalPages: Int?
    let totalResults: Int?
}
