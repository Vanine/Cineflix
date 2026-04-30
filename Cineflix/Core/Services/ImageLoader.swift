//
//  ImageLoader.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 21.02.2026.
//

import SwiftUI

nonisolated protocol ImageLoaderProtocol: Sendable {
    func load(_ url: URL) async throws -> UIImage
}

actor ImageLoader: ImageLoaderProtocol {
    private var cache: [URL: UIImage] = [:]
    private var inflight: [URL: Task<UIImage, Error>] = [:]
    private let session: URLSession
    private let maxEntries: Int

    init(maxEntries: Int = 200) {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: 50 * 1024 * 1024,
                                   diskCapacity: 200 * 1024 * 1024)
        self.session = URLSession(configuration: config)
        self.maxEntries = maxEntries
    }

    func load(_ url: URL) async throws -> UIImage {
        if let cached = cache[url] { return cached }
        if let task = inflight[url] { return try await task.value }

        let task = Task<UIImage, Error> {
            let (data, _) = try await session.data(from: url)
            guard let image = UIImage(data: data) else {
                throw APIError.transport("Invalid image data")
            }
            return image
        }
        inflight[url] = task
        defer { inflight[url] = nil }

        let image = try await task.value
        if cache.count >= maxEntries, let key = cache.keys.first {
            cache.removeValue(forKey: key)
        }
        cache[url] = image
        return image
    }
}
