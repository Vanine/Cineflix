//
//  MovieDetailsView.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 01.03.2026.
//

import SwiftUI
import SwiftData

struct MovieDetailsView: View {
    @StateObject var viewModel: MovieDetailsViewModel
    @EnvironmentObject private var router: AppRouter
    @Environment(\.modelContext) private var modelContext
    @Query private var favorites: [FavoriteMovie]
    @State private var showTrailer = false
    @State private var trailerUnavailableShown = false

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    header
                    actionRow
                    overview
                    if !viewModel.similar.isEmpty {
                        similarSection
                    }
                    Spacer(minLength: DesignSystem.Spacing.xl)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task { viewModel.onAppear() }
        .onDisappear { viewModel.cancel() }
        .fullScreenCover(isPresented: $showTrailer) {
            if let key = viewModel.trailerKey {
                TrailerPlayerView(youtubeKey: key)
            }
        }
        .alert("No trailer available", isPresented: $trailerUnavailableShown) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("We couldn't find a trailer for this movie.")
        }
    }

    private var header: some View {
        DesignSystem.Color.surface
            .frame(height: 480)
            .overlay {
                RemoteImageView(url: viewModel.movie.backdropURL ?? viewModel.movie.posterURL)
                    .allowsHitTesting(false)
            }
            .overlay {
                LinearGradient(
                    colors: [
                        .clear,
                        DesignSystem.Color.background.opacity(0.4),
                        DesignSystem.Color.background.opacity(0.95),
                        DesignSystem.Color.background
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(viewModel.movie.title)
                        .font(DesignSystem.Typography.largeTitle)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: 12) {
                        Label(viewModel.movie.ratingFormatted, systemImage: "star.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(DesignSystem.Color.rating)
                        if !viewModel.movie.year.isEmpty {
                            Text(viewModel.movie.year)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.md)
            }
    }

    private var actionRow: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            if showTrailerButton {
                Button {
                    playTrailer()
                } label: {
                    HStack(spacing: 8) {
                        if viewModel.isLoadingTrailer {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "play.fill")
                        }
                        Text("Play Trailer")
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(DesignSystem.Color.accent, in: .rect(cornerRadius: DesignSystem.Radius.md))
                }
            }

            Button {
                toggleFavorite()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 18, weight: .semibold))
                    if !showTrailerButton {
                        Text(isFavorite ? "In Favorites" : "Add to Favorites")
                            .fontWeight(.semibold)
                    }
                }
                .foregroundStyle(isFavorite ? DesignSystem.Color.accent : .white)
                .frame(maxWidth: showTrailerButton ? nil : .infinity)
                .frame(width: showTrailerButton ? 52 : nil, height: 52)
                .background(DesignSystem.Color.surfaceElevated, in: .rect(cornerRadius: DesignSystem.Radius.md))
            }
            .sensoryFeedback(.success, trigger: isFavorite)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .animation(.easeInOut(duration: 0.2), value: showTrailerButton)
    }

    private var showTrailerButton: Bool {
        !viewModel.hasFetchedVideos || viewModel.trailerKey != nil
    }

    private var overview: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text("Overview")
                .font(DesignSystem.Typography.title)
                .foregroundStyle(.white)
            Text(viewModel.movie.overview ?? "No overview available.")
                .font(DesignSystem.Typography.body)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineSpacing(4)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    private var similarSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "More Like This")
                .padding(.horizontal, DesignSystem.Spacing.md)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: DesignSystem.Spacing.md) {
                    ForEach(viewModel.similar) { movie in
                        Button {
                            router.push(.movieDetails(movie))
                        } label: {
                            MovieCardView(movie: movie, width: 120)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .contentMargins(.horizontal, DesignSystem.Spacing.md, for: .scrollContent)
        }
    }

    private var isFavorite: Bool {
        favorites.contains { $0.id == viewModel.movie.id }
    }

    private func toggleFavorite() {
        if let existing = favorites.first(where: { $0.id == viewModel.movie.id }) {
            modelContext.delete(existing)
        } else {
            modelContext.insert(FavoriteMovie(movie: viewModel.movie))
        }
        try? modelContext.save()
    }

    private func playTrailer() {
        if viewModel.trailerKey != nil {
            showTrailer = true
        } else if viewModel.hasFetchedVideos {
            trailerUnavailableShown = true
        }
    }
}
