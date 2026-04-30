//
//  NetworkService.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 18.02.2026.
//

import Foundation

nonisolated protocol NetworkServiceProtocol: Sendable {
    func get<T: Decodable & Sendable>(_ endpoint: TMDBEndpoint, as type: T.Type) async throws -> T
}

nonisolated final class NetworkService: NetworkServiceProtocol, @unchecked Sendable {
    private let session: URLSession
    private let bearerToken: String
    private let decoder: JSONDecoder
    private let logger: AppLogger

    init(bearerToken: String, logger: AppLogger, session: URLSession = .shared) {
        self.bearerToken = bearerToken
        self.session = session
        self.logger = logger
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    func get<T: Decodable & Sendable>(_ endpoint: TMDBEndpoint, as type: T.Type) async throws -> T {
        guard !bearerToken.isEmpty else { throw APIError.missingToken }
        guard let url = endpoint.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "accept")

        logger.debug("GET \(url.absoluteString)")

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw APIError.transport("Invalid response")
            }
            guard (200..<300).contains(http.statusCode) else {
                throw APIError.requestFailed(statusCode: http.statusCode)
            }
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                logger.error("Decoding failed: \(error)")
                throw APIError.decodingFailed(String(describing: error))
            }
        } catch let error as APIError {
            throw error
        } catch is CancellationError {
            throw APIError.cancelled
        } catch let urlError as URLError where urlError.code == .cancelled {
            throw APIError.cancelled
        } catch {
            throw APIError.transport(error.localizedDescription)
        }
    }
}
