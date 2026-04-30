//
//  SearchView.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 28.02.2026.
//

import SwiftUI

struct SearchView: View {
    @StateObject var viewModel: SearchViewModel
    @EnvironmentObject private var router: AppRouter

    private let columns = [
        GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
        GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
        GridItem(.flexible(), spacing: DesignSystem.Spacing.md)
    ]

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            content
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(DesignSystem.Color.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .searchable(text: $viewModel.query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search movies")
        .onDisappear { viewModel.cancel() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            EmptyStateView(
                systemImage: "magnifyingglass",
                title: "Discover Movies",
                message: "Search by title to find movies you'll love."
            )
        case .loading where viewModel.results.isEmpty:
            ScrollView {
                LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.md) {
                    ForEach(0..<9, id: \.self) { _ in
                        MovieCardSkeleton(width: 100)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
        case .error(let message) where viewModel.results.isEmpty:
            ErrorStateView(message: message) {
                let q = viewModel.query
                viewModel.query = ""
                viewModel.query = q
            }
        case .loaded where viewModel.results.isEmpty:
            EmptyStateView(
                systemImage: "film.stack",
                title: "No results",
                message: "We couldn't find anything matching “\(viewModel.query)”. Try another search."
            )
        default:
            resultsGrid
        }
    }

    private var resultsGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.md) {
                ForEach(viewModel.results) { movie in
                    Button {
                        router.push(.movieDetails(movie))
                    } label: {
                        MovieCardView(movie: movie, width: cardWidth)
                    }
                    .buttonStyle(.plain)
                    .onAppear { viewModel.loadMoreIfNeeded(current: movie) }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xl)
        }
    }

    private var cardWidth: CGFloat {
        let screen = UIScreen.main.bounds.width
        let totalSpacing = DesignSystem.Spacing.md * 4
        return (screen - totalSpacing) / 3
    }
}
