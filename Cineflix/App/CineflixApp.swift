//
//  CineflixApp.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 15.02.2026.
//

import SwiftUI
import SwiftData

@main
struct CineflixApp: App {
    @StateObject private var router = AppRouter()
    private let container: DIContainer

    init() {
        self.container = DIContainer.live()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
                .environment(\.di, container)
                .preferredColorScheme(.dark)
                .tint(DesignSystem.Color.accent)
        }
        .modelContainer(container.modelContainer)
    }
}
