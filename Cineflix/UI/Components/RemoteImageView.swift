//
//  RemoteImageView.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 24.02.2026.
//

import SwiftUI

struct RemoteImageView: View {
    let url: URL?
    var contentMode: ContentMode = .fill

    @Environment(\.di) private var di
    @State private var image: UIImage?
    @State private var loadTask: Task<Void, Never>?
    @State private var failed: Bool = false

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .transition(.opacity)
            } else if failed {
                placeholder(systemName: "film")
            } else {
                SkeletonShimmer()
            }
        }
        .onAppear { load() }
        .onDisappear {
            loadTask?.cancel()
            loadTask = nil
        }
        .onChange(of: url) { _, _ in
            image = nil
            failed = false
            load()
        }
    }

    private func load() {
        guard image == nil, let url else {
            if url == nil { failed = true }
            return
        }
        loadTask?.cancel()
        loadTask = Task {
            do {
                let result = try await di.imageLoader.load(url)
                if Task.isCancelled { return }
                await MainActor.run {
                    withAnimation(.easeOut(duration: 0.2)) {
                        self.image = result
                    }
                }
            } catch {
                if Task.isCancelled { return }
                await MainActor.run { self.failed = true }
            }
        }
    }

    private func placeholder(systemName: String) -> some View {
        ZStack {
            DesignSystem.Color.surface
            Image(systemName: systemName)
                .font(.system(size: 28))
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }
}
