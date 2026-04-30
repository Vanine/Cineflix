//
//  RecentlyViewedService.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 21.02.2026.
//

import Foundation

nonisolated protocol RecentlyViewedServiceProtocol: Sendable {
    func record(_ movie: Movie) async
    func all() async -> [Movie]
}

actor RecentlyViewedService: RecentlyViewedServiceProtocol {
    private let key = "cineflix.recently_viewed"
    private let limit = 20

    func record(_ movie: Movie) {
        var items = loadFromDefaults()
        items.removeAll { $0.id == movie.id }
        items.insert(movie, at: 0)
        if items.count > limit { items = Array(items.prefix(limit)) }
        saveToDefaults(items)
    }

    func all() -> [Movie] {
        loadFromDefaults()
    }

    private func loadFromDefaults() -> [Movie] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([Movie].self, from: data)) ?? []
    }

    private func saveToDefaults(_ items: [Movie]) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
