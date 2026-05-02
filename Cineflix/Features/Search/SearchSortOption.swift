//
//  SearchSortOption.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 04.03.2026.
//

import Foundation

enum SearchSortOption: String, CaseIterable, Identifiable, Sendable {
    case relevance
    case ratingDesc
    case releaseDateDesc
    case releaseDateAsc

    var id: String { rawValue }

    var title: String {
        switch self {
        case .relevance: return "Relevance"
        case .ratingDesc: return "Top Rated"
        case .releaseDateDesc: return "Newest"
        case .releaseDateAsc: return "Oldest"
        }
    }

    var systemImage: String {
        switch self {
        case .relevance: return "sparkles"
        case .ratingDesc: return "star.fill"
        case .releaseDateDesc: return "calendar.badge.clock"
        case .releaseDateAsc: return "clock.arrow.circlepath"
        }
    }
}
