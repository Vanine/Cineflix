//
//  SearchSortBar.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 04.03.2026.
//

import SwiftUI

struct SearchSortBar: View {
    @Binding var selection: SearchSortOption
    @Namespace private var indicator

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(SearchSortOption.allCases) { option in
                    chip(for: option)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .contentMargins(.horizontal, DesignSystem.Spacing.md, for: .scrollContent)
        .scrollClipDisabled()
    }

    private func chip(for option: SearchSortOption) -> some View {
        let isSelected = selection == option

        return Button {
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
            withAnimation(.spring(response: 0.42, dampingFraction: 0.78)) {
                selection = option
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: option.systemImage)
                    .font(.system(size: 12, weight: .bold))
                    .symbolEffect(.bounce, value: isSelected)
                Text(option.title)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(isSelected ? .white : DesignSystem.Color.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background {
                if isSelected {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    DesignSystem.Color.accent,
                                    DesignSystem.Color.accent.opacity(0.75)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: DesignSystem.Color.accent.opacity(0.45), radius: 10, x: 0, y: 4)
                        .matchedGeometryEffect(id: "sortIndicator", in: indicator)
                } else {
                    Capsule()
                        .fill(DesignSystem.Color.surface)
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                }
            }
        }
        .buttonStyle(.plain)
    }
}
