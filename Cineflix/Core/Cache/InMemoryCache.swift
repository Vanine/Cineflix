//
//  InMemoryCache.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 19.02.2026.
//

import Foundation

nonisolated protocol CacheProtocol: Sendable {
    func value(forKey key: String) async -> Data?
    func setValue(_ data: Data, forKey key: String) async
    func clear() async
}

actor InMemoryCache: CacheProtocol {
    private var storage: [String: Data] = [:]
    private let maxEntries: Int

    init(maxEntries: Int = 100) {
        self.maxEntries = maxEntries
    }

    func value(forKey key: String) -> Data? {
        storage[key]
    }

    func setValue(_ data: Data, forKey key: String) {
        if storage.count >= maxEntries, let firstKey = storage.keys.first {
            storage.removeValue(forKey: firstKey)
        }
        storage[key] = data
    }

    func clear() {
        storage.removeAll()
    }
}
