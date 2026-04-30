//
//  FavoriteMovie.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 16.02.2026.
//

import Foundation
import SwiftData

@Model
final class FavoriteMovie {
    @Attribute(.unique) var id: Int
    var title: String
    var overview: String?
    var posterPath: String?
    var backdropPath: String?
    var voteAverage: Double?
    var releaseDate: String?
    var addedAt: Date

    init(movie: Movie) {
        self.id = movie.id
        self.title = movie.title
        self.overview = movie.overview
        self.posterPath = movie.posterPath
        self.backdropPath = movie.backdropPath
        self.voteAverage = movie.voteAverage
        self.releaseDate = movie.releaseDate
        self.addedAt = Date()
    }

    var asMovie: Movie {
        Movie(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            voteAverage: voteAverage,
            releaseDate: releaseDate
        )
    }
}
