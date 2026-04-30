//
//  DesignSystem.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 23.02.2026.
//

import SwiftUI

enum DesignSystem {
    enum Color {
        static let background = SwiftUI.Color(red: 0.07, green: 0.07, blue: 0.08)
        static let surface = SwiftUI.Color(red: 0.13, green: 0.13, blue: 0.15)
        static let surfaceElevated = SwiftUI.Color(red: 0.18, green: 0.18, blue: 0.21)
        static let accent = SwiftUI.Color(red: 0.90, green: 0.10, blue: 0.16)
        static let textPrimary = SwiftUI.Color.white
        static let textSecondary = SwiftUI.Color.white.opacity(0.7)
        static let textTertiary = SwiftUI.Color.white.opacity(0.45)
        static let rating = SwiftUI.Color(red: 1.0, green: 0.78, blue: 0.18)
    }

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
    }

    enum Typography {
        static let largeTitle = Font.system(size: 32, weight: .heavy, design: .default)
        static let title = Font.system(size: 22, weight: .bold, design: .default)
        static let sectionTitle = Font.system(size: 20, weight: .bold, design: .default)
        static let body = Font.system(size: 15, weight: .regular)
        static let cardTitle = Font.system(size: 13, weight: .semibold)
        static let caption = Font.system(size: 12, weight: .medium)
    }
}
