//
//  Video.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 16.02.2026.
//

import Foundation

nonisolated struct Video: Codable, Hashable, Identifiable, Sendable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
    let official: Bool?

    var isYouTubeTrailer: Bool {
        site.lowercased() == "youtube" && type.lowercased() == "trailer"
    }
}

nonisolated struct VideoResponse: Codable, Sendable {
    let id: Int
    let results: [Video]
}
