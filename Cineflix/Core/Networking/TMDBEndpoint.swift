//
//  TMDBEndpoint.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 17.02.2026.
//

import Foundation

nonisolated enum TMDBEndpoint: Sendable {
    case trending(page: Int)
    case popular(page: Int)
    case topRated(page: Int)
    case search(query: String, page: Int)
    case similar(movieID: Int, page: Int)
    case videos(movieID: Int)

    private static let host = AppConstants.API.host
    private static let basePath = AppConstants.API.basePath

    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Self.host

        switch self {
        case .trending(let page):
            components.path = "\(Self.basePath)/trending/movie/week"
            components.queryItems = [URLQueryItem(name: "page", value: "\(page)")]
        case .popular(let page):
            components.path = "\(Self.basePath)/movie/popular"
            components.queryItems = [URLQueryItem(name: "page", value: "\(page)")]
        case .topRated(let page):
            components.path = "\(Self.basePath)/movie/top_rated"
            components.queryItems = [URLQueryItem(name: "page", value: "\(page)")]
        case .search(let query, let page):
            components.path = "\(Self.basePath)/search/movie"
            components.queryItems = [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "include_adult", value: "false")
            ]
        case .similar(let id, let page):
            components.path = "\(Self.basePath)/movie/\(id)/similar"
            components.queryItems = [URLQueryItem(name: "page", value: "\(page)")]
        case .videos(let id):
            components.path = "\(Self.basePath)/movie/\(id)/videos"
        }
        return components.url
    }
}

nonisolated enum TMDBImage {
    static func poster(path: String?, size: String = AppConstants.Image.posterSize) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        return URL(string: "\(AppConstants.API.imageBaseURL)/\(size)\(path)")
    }

    static func backdrop(path: String?, size: String = AppConstants.Image.backdropSize) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        return URL(string: "\(AppConstants.API.imageBaseURL)/\(size)\(path)")
    }
}
