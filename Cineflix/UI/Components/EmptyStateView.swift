//
//  EmptyStateView.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 25.02.2026.
//

import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(DesignSystem.Color.textTertiary)
            Text(title)
                .font(DesignSystem.Typography.title)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(message)
                .font(DesignSystem.Typography.body)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorStateView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundStyle(DesignSystem.Color.accent)
            Text("Something went wrong")
                .font(DesignSystem.Typography.title)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(message)
                .font(DesignSystem.Typography.body)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.xl)
            Button(action: retry) {
                Text("Try again")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background(DesignSystem.Color.accent, in: .capsule)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
