//
//  FavoritesView.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 03.03.2026.
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: AppRouter
    @Query(sort: \FavoriteMovie.addedAt, order: .reverse) private var favorites: [FavoriteMovie]

    private let columns = [
        GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
        GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
        GridItem(.flexible(), spacing: DesignSystem.Spacing.md)
    ]

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            if favorites.isEmpty {
                EmptyStateView(
                    systemImage: "heart.slash",
                    title: "No Favorites Yet",
                    message: "Tap the heart on any movie to save it here for later."
                )
            } else {
                grid
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(DesignSystem.Color.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var grid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.md) {
                ForEach(favorites) { fav in
                    Button {
                        router.push(.movieDetails(fav.asMovie))
                    } label: {
                        MovieCardView(movie: fav.asMovie, width: cardWidth)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            modelContext.delete(fav)
                            try? modelContext.save()
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
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
