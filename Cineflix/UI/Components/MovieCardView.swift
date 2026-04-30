//
//  MovieCardView.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 25.02.2026.
//

import SwiftUI

struct MovieCardView: View {
    let movie: Movie
    var width: CGFloat = 130

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            DesignSystem.Color.surface
                .frame(width: width, height: width * 1.5)
                .overlay {
                    RemoteImageView(url: movie.posterURL)
                        .allowsHitTesting(false)
                }
                .clipShape(.rect(cornerRadius: DesignSystem.Radius.md))
                .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                .overlay(alignment: .topTrailing) {
                    if movie.voteAverage ?? 0 > 0 {
                        ratingBadge
                            .padding(8)
                    }
                }

            Text(movie.title)
                .font(DesignSystem.Typography.cardTitle)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
                .frame(width: width, alignment: .leading)
        }
    }

    private var ratingBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(DesignSystem.Color.rating)
            Text(movie.ratingFormatted)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(.black.opacity(0.65), in: .capsule)
    }
}

struct MovieCardSkeleton: View {
    var width: CGFloat = 130

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            SkeletonShimmer()
                .frame(width: width, height: width * 1.5)
                .clipShape(.rect(cornerRadius: DesignSystem.Radius.md))
            SkeletonShimmer()
                .frame(width: width * 0.7, height: 12)
                .clipShape(.rect(cornerRadius: 4))
        }
    }
}
