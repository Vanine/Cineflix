//
//  AppConstants.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 16.02.2026.
//

import Foundation

nonisolated enum AppConstants {
    enum API {
        static let host: String = "api.themoviedb.org"
        static let basePath: String = "/3"
        static let imageBaseURL: String = "https://image.tmdb.org/t/p"
        static let youTubeEmbedBaseURL: String = "https://www.youtube.com/embed"
        static let bearerToken: String = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJiMzQxNmZhNWViNjNiMTE5ZmNlMTkxOGViYzIzNDI0YiIsIm5iZiI6MTc3NzQ5NDM4MS40MDksInN1YiI6IjY5ZjI2OTZkNzk0MGEzOGY0MDdiZWY3MSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.eg_2v1edwso_rMXDDsf5FjGOpzKppDKqMXOq3YKpnJs"
    }

    enum Image {
        static let posterSize: String = "w500"
        static let backdropSize: String = "w780"
    }

    enum Pagination {
        static let firstPage: Int = 1
    }

    enum Search {
        static let debounceMilliseconds: Int = 300
    }

    enum Logging {
        static let subsystem: String = "com.cineflix.app"
    }
}
