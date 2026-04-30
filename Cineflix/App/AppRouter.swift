//
//  AppRouter.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 22.02.2026.
//

import SwiftUI
import Combine

enum AppTab: Hashable {
    case home, search, favorites
}

enum AppRoute: Hashable {
    case movieDetails(Movie)
}

final class AppRouter: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published var homePath = NavigationPath()
    @Published var searchPath = NavigationPath()
    @Published var favoritesPath = NavigationPath()

    @Published var presentedTrailerKey: String?
    @Published var trailerLoading: Bool = false
    @Published var trailerError: String?

    func push(_ route: AppRoute) {
        switch selectedTab {
        case .home: homePath.append(route)
        case .search: searchPath.append(route)
        case .favorites: favoritesPath.append(route)
        }
    }

    func popToRoot() {
        switch selectedTab {
        case .home: homePath = NavigationPath()
        case .search: searchPath = NavigationPath()
        case .favorites: favoritesPath = NavigationPath()
        }
    }
}

struct AppNavigationDestinationsModifier: ViewModifier {
    @Environment(\.di) private var di

    func body(content: Content) -> some View {
        content.navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .movieDetails(let movie):
                MovieDetailsView(
                    viewModel: MovieDetailsViewModel(
                        movie: movie,
                        service: di.movieService,
                        recentlyViewed: di.recentlyViewed,
                        logger: di.logger
                    )
                )
            }
        }
    }
}

extension View {
    func navigationDestinationsForApp() -> some View {
        modifier(AppNavigationDestinationsModifier())
    }
}
