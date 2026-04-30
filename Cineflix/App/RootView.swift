//
//  RootView.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 03.03.2026.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(\.di) private var di

    var body: some View {
        TabView(selection: $router.selectedTab) {
            NavigationStack(path: $router.homePath) {
                HomeView(viewModel: HomeViewModel(service: di.movieService, logger: di.logger))
                    .navigationDestinationsForApp()
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(AppTab.home)

            NavigationStack(path: $router.searchPath) {
                SearchView(viewModel: SearchViewModel(service: di.movieService, logger: di.logger))
                    .navigationDestinationsForApp()
            }
            .tabItem { Label("Search", systemImage: "magnifyingglass") }
            .tag(AppTab.search)

            NavigationStack(path: $router.favoritesPath) {
                FavoritesView()
                    .navigationDestinationsForApp()
            }
            .tabItem { Label("Favorites", systemImage: "heart.fill") }
            .tag(AppTab.favorites)
        }
    }
}
