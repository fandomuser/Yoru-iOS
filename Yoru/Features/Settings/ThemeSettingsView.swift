import SwiftUI

public struct ThemeSettingsView: View {
    @Environment(\.yoruTheme) private var theme
    private let themeManager = ThemeManager.shared
    private let onBack: () -> Void

    public init(onBack: @escaping () -> Void) {
        self.onBack = onBack
    }

    public var body: some View {
        ZStack {
            theme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(theme.accentSecondary)
                    }

                    Text("THEME STUDIO")
                        .font(.yoruTitle)
                        .foregroundColor(theme.textPrimary)

                    Spacer()

                    CyberTag("5 PRESETS", kanji: "美学")
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 24) {
                        // Theme Presets
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SELECT VISUAL PRESET")
                                .font(.yoruCyberBadge)
                                .foregroundColor(theme.accentSecondary)
                                .padding(.horizontal, 16)

                            VStack(spacing: 12) {
                                ForEach(ThemeID.allCases) { themeID in
                                    let isSelected = themeManager.currentThemeID == themeID
                                    let sampleTheme = YoruThemes.theme(for: themeID)

                                    Button(action: {
                                        themeManager.selectTheme(themeID)
                                    }) {
                                        HStack(spacing: 14) {
                                            // Theme Color Swatches
                                            HStack(spacing: 4) {
                                                Circle().fill(sampleTheme.backgroundPrimary).frame(width: 14, height: 14)
                                                Circle().fill(sampleTheme.accentPrimary).frame(width: 14, height: 14)
                                                Circle().fill(sampleTheme.accentSecondary).frame(width: 14, height: 14)
                                            }
                                            .padding(6)
                                            .background(Color.black.opacity(0.4))
                                            .cornerRadius(12)

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(themeID.displayName)
                                                    .font(.yoruHeadline)
                                                    .foregroundColor(sampleTheme.textPrimary)

                                                Text(themeID.subtitle)
                                                    .font(.yoruCaption)
                                                    .foregroundColor(sampleTheme.textSecondary)
                                                    .lineLimit(1)
                                            }

                                            Spacer()

                                            if isSelected {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(sampleTheme.accentSecondary)
                                            }
                                        }
                                        .padding(14)
                                        .background(sampleTheme.glassSurface.opacity(0.85))
                                        .cornerRadius(14)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(
                                                    isSelected ? sampleTheme.accentPrimary : Color.white.opacity(0.08),
                                                    lineWidth: isSelected ? 2 : 1
                                                )
                                        )
                                        .yoruNeonGlow(color: sampleTheme.neonGlow, radius: 6, isActive: isSelected)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        // Customization Controls
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ADVANCED VISUAL CONTROLS")
                                .font(.yoruCyberBadge)
                                .foregroundColor(theme.accentSecondary)
                                .padding(.horizontal, 16)

                            CyberCard(cornerCut: 12) {
                                VStack(spacing: 16) {
                                    Toggle(isOn: Binding(
                                        get: { themeManager.enableNeonGlow },
                                        set: { themeManager.enableNeonGlow = $0 }
                                    )) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Neon Hologram Glow")
                                                .font(.yoruHeadline)
                                                .foregroundColor(theme.textPrimary)
                                            Text("Shader-driven neon luminescence on active components")
                                                .font(.yoruCaption)
                                                .foregroundColor(theme.textSecondary)
                                        }
                                    }
                                    .tint(theme.accentPrimary)

                                    Divider().background(Color.white.opacity(0.1))

                                    Toggle(isOn: Binding(
                                        get: { themeManager.enableAnimeTransitions },
                                        set: { themeManager.enableAnimeTransitions = $0 }
                                    )) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Snappy Spring Transitions")
                                                .font(.yoruHeadline)
                                                .foregroundColor(theme.textPrimary)
                                            Text("Physics-based spring curves optimized for 120Hz ProMotion")
                                                .font(.yoruCaption)
                                                .foregroundColor(theme.textSecondary)
                                        }
                                    }
                                    .tint(theme.accentPrimary)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}
