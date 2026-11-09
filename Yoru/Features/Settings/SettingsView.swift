import SwiftUI

public struct SettingsView: View {
    @Environment(\.yoruTheme) private var theme
    @State private var viewModel = SettingsViewModel()
    private let onOpenThemes: () -> Void
    private let onOpenSecurity: () -> Void
    private let onOpenProfile: () -> Void
    private let onOpenLabs: () -> Void

    public init(
        onOpenThemes: @escaping () -> Void,
        onOpenSecurity: @escaping () -> Void,
        onOpenProfile: @escaping () -> Void,
        onOpenLabs: @escaping () -> Void
    ) {
        self.onOpenThemes = onOpenThemes
        self.onOpenSecurity = onOpenSecurity
        self.onOpenProfile = onOpenProfile
        self.onOpenLabs = onOpenLabs
    }

    public var body: some View {
        ZStack {
            theme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("SETTINGS")
                                .font(.yoruTitle)
                                .foregroundColor(theme.textPrimary)
                            Text("設定")
                                .font(.yoruKanjiAccent)
                                .foregroundColor(theme.accentSecondary.opacity(0.8))
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 18) {
                        // Profile Banner Card
                        Button(action: onOpenProfile) {
                            CyberCard(cornerCut: 14) {
                                HStack(spacing: 14) {
                                    YoruAvatarView(
                                        name: viewModel.currentUser.fullName,
                                        size: 58,
                                        isOnline: true
                                    )

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(viewModel.currentUser.fullName)
                                            .font(.yoruHeadline)
                                            .foregroundColor(theme.textPrimary)

                                        if let username = viewModel.currentUser.username {
                                            Text("@\(username)")
                                                .font(.yoruSubheadline)
                                                .foregroundColor(theme.accentPrimary)
                                        }

                                        Text(viewModel.currentUser.phoneNumber)
                                            .font(.yoruCaption)
                                            .foregroundColor(theme.textTertiary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(theme.textTertiary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.top, 6)

                        // Yoru Labs Entrypoint Card
                        Button(action: onOpenLabs) {
                            CyberCard(cornerCut: 14) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [theme.accentPrimary, theme.accentSecondary],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 44, height: 44)
                                        Image(systemName: "flask.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(theme.textInverse)
                                    }
                                    .yoruNeonGlow(color: theme.neonGlow, radius: 6)

                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack(spacing: 6) {
                                            Text("YORU LABS")
                                                .font(.yoruHeadline)
                                                .foregroundColor(theme.textPrimary)
                                            CyberTag("AYUGRAM", kanji: "実験")
                                        }

                                        Text("Ghost Mode, Anti-Recall, Filters & Streamer")
                                            .font(.yoruCaption)
                                            .foregroundColor(theme.textSecondary)
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(theme.accentSecondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)

                        // Visual Customization Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("VISUAL MATRIX")
                                .font(.yoruCyberBadge)
                                .foregroundColor(theme.accentSecondary)
                                .padding(.horizontal, 16)

                            CyberCard(cornerCut: 12) {
                                Button(action: onOpenThemes) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "paintpalette.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(theme.accentPrimary)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Theme Studio (5 Themes)")
                                                .font(.yoruHeadline)
                                                .foregroundColor(theme.textPrimary)
                                            Text(theme.name)
                                                .font(.yoruCaption)
                                                .foregroundColor(theme.accentSecondary)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(theme.textTertiary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 16)
                        }

                        // Security & Privacy Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SECURITY & HARDWARE")
                                .font(.yoruCyberBadge)
                                .foregroundColor(theme.accentSecondary)
                                .padding(.horizontal, 16)

                            CyberCard(cornerCut: 12) {
                                Button(action: onOpenSecurity) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "shield.checkered")
                                            .font(.system(size: 20))
                                            .foregroundColor(theme.onlineStatus)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Security & Privacy")
                                                .font(.yoruHeadline)
                                                .foregroundColor(theme.textPrimary)
                                            Text("Keychain encryption & biometrics")
                                                .font(.yoruCaption)
                                                .foregroundColor(theme.textSecondary)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(theme.textTertiary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 16)
                        }

                        // Storage & Data
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DATA & CACHE")
                                .font(.yoruCyberBadge)
                                .foregroundColor(theme.accentSecondary)
                                .padding(.horizontal, 16)

                            CyberCard(cornerCut: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: "internaldrive.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(theme.accentSecondary)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Local Cache Storage")
                                            .font(.yoruHeadline)
                                            .foregroundColor(theme.textPrimary)
                                        Text(viewModel.cacheSize)
                                            .font(.yoruCaption)
                                            .foregroundColor(theme.textSecondary)
                                    }

                                    Spacer()

                                    Button("Purge") {
                                        viewModel.clearCache()
                                    }
                                    .font(.yoruCaption)
                                    .foregroundColor(theme.accentPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(theme.accentPrimary.opacity(0.15))
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        // Logout Button
                        YoruButton("TERMINATE SESSION", kanji: "切断", icon: "power", style: .destructive, isLoading: viewModel.isLoggingOut) {
                            viewModel.logOut()
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 36)
                }
            }
        }
    }
}
