//
//  DIContainer.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 22.02.2026.
//

import SwiftUI
import SwiftData

struct DIContainer {
    let networkService: NetworkServiceProtocol
    let movieService: MovieServiceProtocol
    let imageLoader: ImageLoaderProtocol
    let recentlyViewed: RecentlyViewedServiceProtocol
    let logger: AppLogger
    let modelContainer: ModelContainer

    static func live() -> DIContainer {
        let logger = AppLogger(subsystem: AppConstants.Logging.subsystem, category: "App")
        let network = NetworkService(
            bearerToken: AppConstants.API.bearerToken,
            logger: logger
        )
        let movieService = MovieService(network: network, cache: InMemoryCache(), logger: logger)
        let imageLoader = ImageLoader()
        let recentlyViewed = RecentlyViewedService()

        let schema = Schema([FavoriteMovie.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        let container: ModelContainer
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }

        return DIContainer(
            networkService: network,
            movieService: movieService,
            imageLoader: imageLoader,
            recentlyViewed: recentlyViewed,
            logger: logger,
            modelContainer: container
        )
    }
}

private struct DIContainerKey: EnvironmentKey {
    static let defaultValue: DIContainer = DIContainer.live()
}

extension EnvironmentValues {
    var di: DIContainer {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}
