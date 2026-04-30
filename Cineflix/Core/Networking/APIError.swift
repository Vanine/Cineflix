//
//  APIError.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 17.02.2026.
//

import Foundation

nonisolated enum APIError: LocalizedError, Sendable {
    case invalidURL
    case missingToken
    case requestFailed(statusCode: Int)
    case decodingFailed(String)
    case transport(String)
    case cancelled

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .missingToken: return "TMDB token is not configured."
        case .requestFailed(let code): return "Request failed with status \(code)."
        case .decodingFailed(let info): return "Failed to decode response: \(info)"
        case .transport(let info): return "Network error: \(info)"
        case .cancelled: return "Request cancelled."
        }
    }
}
