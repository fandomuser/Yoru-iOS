import SwiftUI

public struct EmptyStateView: View {
    @Environment(\.yoruTheme) private var theme
    private let title: String
    private let subtitle: String
    private let kanji: String
    private let systemIcon: String

    public init(
        title: String,
        subtitle: String,
        kanji: String = "無",
        systemIcon: String = "antenna.radiowaves.left.and.right.slash"
    ) {
        self.title = title
        self.subtitle = subtitle
        self.kanji = kanji
        self.systemIcon = systemIcon
    }

    public var body: some View {
        VStack(spacing: 20) {
            MangaGraphicView(kanji: kanji, icon: systemIcon)

            VStack(spacing: 8) {
                Text(title)
                    .font(.yoruTitle)
                    .foregroundColor(theme.textPrimary)

                Text(subtitle)
                    .font(.yoruBody)
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .padding(.vertical, 40)
    }
}

public struct MangaGraphicView: View {
    @Environment(\.yoruTheme) private var theme
    let kanji: String
    let icon: String

    public var body: some View {
        ZStack {
            // Anime concentric circle radar/portal effect
            Circle()
                .stroke(theme.accentPrimary.opacity(0.15), lineWidth: 1)
                .frame(width: 140, height: 140)

            Circle()
                .stroke(theme.accentSecondary.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                .frame(width: 110, height: 110)

            Circle()
                .fill(theme.glassSurface.opacity(0.7))
                .frame(width: 80, height: 80)
                .overlay(Circle().stroke(theme.accentPrimary.opacity(0.5), lineWidth: 1))

            Text(kanji)
                .font(.system(size: 44, weight: .black, design: .serif))
                .foregroundColor(theme.accentPrimary.opacity(0.25))
                .offset(y: -4)

            Image(systemName: icon)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(theme.accentSecondary)
                .yoruNeonGlow(color: theme.neonGlow, radius: 6)
        }
    }
}
