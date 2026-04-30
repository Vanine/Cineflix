//
//  SectionHeaderView.swift
//  Cineflix
//
//  Created by Vanine Ghazaryan on 25.02.2026.
//

import SwiftUI

struct SectionHeaderView: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(DesignSystem.Typography.sectionTitle)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            if let subtitle {
                Text(subtitle)
                    .font(DesignSystem.Typography.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
        }
    }
}
