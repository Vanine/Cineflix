//
//  SkeletonShimmer.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 24.02.2026.
//

import SwiftUI

struct SkeletonShimmer: View {
    @State private var phase: CGFloat = -1

    var body: some View {
        Rectangle()
            .fill(DesignSystem.Color.surface)
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.08),
                        Color.white.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase * 250)
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}
