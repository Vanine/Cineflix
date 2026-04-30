//
//  HomeView.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 27.02.2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @EnvironmentObject private var router: AppRouter
    @Environment(\.di) private var di
    @State private var recentlyViewed: [Movie] = []

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()

            if viewModel.trending.isEmpty {
                switch viewModel.state {
                case .error(let message):
                    ErrorStateView(message: message) {
                        Task { await viewModel.refresh() }
                    }
                default:
                    loadingPlaceholder
                }
            } else {
                content
            }
        }
        .navigationTitle("Cineflix")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(DesignSystem.Color.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            viewModel.onAppear()
            recentlyViewed = await di.recentlyViewed.all()
        }
        .onDisappear { viewModel.cancel() }
        .refreshable {
            await viewModel.refresh()
            recentlyViewed = await di.recentlyViewed.all()
        }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                heroSection
                section(title: "Trending This Week", movies: viewModel.trending) { movie in
                    viewModel.loadMoreTrendingIfNeeded(current: movie)
                }
                section(title: "Popular", movies: viewModel.popular) { movie in
                    viewModel.loadMorePopularIfNeeded(current: movie)
                }
                section(title: "Top Rated", movies: viewModel.topRated) { movie in
                    viewModel.loadMoreTopRatedIfNeeded(current: movie)
                }
                if !recentlyViewed.isEmpty {
                    staticSection(title: "Recently Viewed", movies: recentlyViewed)
                }
                Spacer(minLength: DesignSystem.Spacing.xl)
            }
            .padding(.top, DesignSystem.Spacing.xs)
            .padding(.bottom, DesignSystem.Spacing.md)
        }
    }

    private var heroSection: some View {
        Group {
            if let featured = viewModel.trending.first {
                Button {
                    router.push(.movieDetails(featured))
                } label: {
                    DesignSystem.Color.surface
                        .frame(height: 440)
                        .overlay {
                            RemoteImageView(url: featured.posterURL)
                                .allowsHitTesting(false)
                        }
                        .overlay {
                            LinearGradient(
                                colors: [.clear, .clear, DesignSystem.Color.background.opacity(0.85), DesignSystem.Color.background],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .allowsHitTesting(false)
                        }
                        .overlay(alignment: .bottomLeading) {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                Text("FEATURED")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(2)
                                    .foregroundStyle(DesignSystem.Color.accent)
                                Text(featured.title)
                                    .font(DesignSystem.Typography.largeTitle)
                                    .foregroundStyle(.white)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                HStack(spacing: 12) {
                                    Label(featured.ratingFormatted, systemImage: "star.fill")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(DesignSystem.Color.rating)
                                    if !featured.year.isEmpty {
                                        Text(featured.year)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(DesignSystem.Color.textSecondary)
                                    }
                                }
                            }
                            .padding(DesignSystem.Spacing.lg)
                        }
                        .clipShape(.rect(cornerRadius: DesignSystem.Radius.lg))
                        .padding(.horizontal, DesignSystem.Spacing.md)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func section(title: String, movies: [Movie], onAppear: @escaping (Movie) -> Void) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: title)
                .padding(.horizontal, DesignSystem.Spacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: DesignSystem.Spacing.md) {
                    if movies.isEmpty {
                        ForEach(0..<6, id: \.self) { _ in
                            MovieCardSkeleton()
                        }
                    } else {
                        ForEach(movies) { movie in
                            Button {
                                router.push(.movieDetails(movie))
                            } label: {
                                MovieCardView(movie: movie)
                            }
                            .buttonStyle(.plain)
                            .onAppear { onAppear(movie) }
                        }
                    }
                }
            }
            .contentMargins(.horizontal, DesignSystem.Spacing.md, for: .scrollContent)
        }
    }

    private func staticSection(title: String, movies: [Movie]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: title)
                .padding(.horizontal, DesignSystem.Spacing.md)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: DesignSystem.Spacing.md) {
                    ForEach(movies) { movie in
                        Button { router.push(.movieDetails(movie)) } label: {
                            MovieCardView(movie: movie, width: 110)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .contentMargins(.horizontal, DesignSystem.Spacing.md, for: .scrollContent)
        }
    }

    private var loadingPlaceholder: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                SkeletonShimmer()
                    .frame(height: 440)
                    .clipShape(.rect(cornerRadius: DesignSystem.Radius.lg))
                    .padding(.horizontal, DesignSystem.Spacing.md)

                ForEach(0..<3, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        SkeletonShimmer()
                            .frame(width: 180, height: 22)
                            .clipShape(.rect(cornerRadius: 4))
                            .padding(.horizontal, DesignSystem.Spacing.md)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DesignSystem.Spacing.md) {
                                ForEach(0..<5, id: \.self) { _ in
                                    MovieCardSkeleton()
                                }
                            }
                            .padding(.horizontal, DesignSystem.Spacing.md)
                        }
                    }
                }
            }
            .padding(.vertical, DesignSystem.Spacing.md)
        }
    }
}
