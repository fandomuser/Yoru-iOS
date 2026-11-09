import SwiftUI

public struct YoruLabsView: View {
    @Environment(\.yoruTheme) private var theme
    private let labs = YoruLabsManager.shared
    private let onBack: () -> Void
    private let onNavigate: (LabsDestination) -> Void

    public enum LabsDestination: Hashable {
        case privacy
        case history
        case filters
        case appearance
        case chat
        case translation
        case ai
        case advanced
    }

    public init(onBack: @escaping () -> Void, onNavigate: @escaping (LabsDestination) -> Void) {
        self.onBack = onBack
        self.onNavigate = onNavigate
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

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("YORU LABS")
                                .font(.yoruTitle)
                                .foregroundColor(theme.textPrimary)
                            Text("実験室")
                                .font(.yoruKanjiAccent)
                                .foregroundColor(theme.accentSecondary.opacity(0.8))
                        }
                    }

                    Spacer()

                    CyberTag("AYUGRAM EXT", kanji: "拡張")
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 14) {
                        // Introduction Banner
                        CyberCard(cornerCut: 14) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("NEXT-GEN TELEGRAM CLIENT ENHANCEMENTS")
                                    .font(.yoruCyberBadge)
                                    .foregroundColor(theme.accentSecondary)

                                Text("Extensible client-side privacy, anti-recall message archiving, cyber filters, and streamer identity protection inspired by AyuGram.")
                                    .font(.yoruBody)
                                    .foregroundColor(theme.textSecondary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 6)

                        // 8 Module Navigation Rows
                        moduleRow(
                            icon: "eye.slash.fill",
                            title: "Privacy & Activity (Ghost)",
                            subtitle: "Stealth mode, typing suppression, biometric lock",
                            destination: .privacy,
                            isActive: labs.currentSettings.privacy.stealthModeEnabled
                        )

                        moduleRow(
                            icon: "clock.arrow.circlepath",
                            title: "Message History & Anti-Recall",
                            subtitle: "Save deleted messages and revision edit history",
                            destination: .history,
                            isActive: labs.currentSettings.history.antiRecallEnabled
                        )

                        moduleRow(
                            icon: "line.3.horizontal.decrease.circle.fill",
                            title: "Message Filters & Firewall",
                            subtitle: "Keyword drops, crypto spam filters, spoiler blur",
                            destination: .filters,
                            isActive: labs.currentSettings.filters.filterEnabled
                        )

                        moduleRow(
                            icon: "circle.hexagongrid.fill",
                            title: "Appearance & Geometry",
                            subtitle: "Avatar shapes, bubble radius, hidden UI elements",
                            destination: .appearance,
                            isActive: true
                        )

                        moduleRow(
                            icon: "bolt.shield.fill",
                            title: "Chat Enhancements",
                            subtitle: "Send confirmation dialogs, double-tap actions",
                            destination: .chat,
                            isActive: labs.currentSettings.chat.sendConfirmationChannel
                        )

                        moduleRow(
                            icon: "character.bubble.fill",
                            title: "Translation Engine",
                            subtitle: "Inline message translation & foreign channels",
                            destination: .translation,
                            isActive: labs.currentSettings.translation.translationEnabled
                        )

                        moduleRow(
                            icon: "brain.head.profile",
                            title: "AI Tools & Neural Agents",
                            subtitle: "Smart replies, summaries, anime persona",
                            destination: .ai,
                            isActive: labs.currentSettings.ai.aiEnabled
                        )

                        moduleRow(
                            icon: "video.badge.waveform.fill",
                            title: "Advanced & Streamer Mode",
                            subtitle: "Global dox protection, TDLib debug console",
                            destination: .advanced,
                            isActive: labs.currentSettings.advanced.streamerModeEnabled
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 36)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }

    private func moduleRow(
        icon: String,
        title: String,
        subtitle: String,
        destination: LabsDestination,
        isActive: Bool
    ) -> some View {
        Button(action: { onNavigate(destination) }) {
            CyberCard(cornerCut: 12) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(theme.backgroundElevated)
                            .frame(width: 42, height: 42)
                        Image(systemName: icon)
                            .font(.system(size: 18))
                            .foregroundColor(theme.accentPrimary)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.yoruHeadline)
                            .foregroundColor(theme.textPrimary)

                        Text(subtitle)
                            .font(.yoruCaption)
                            .foregroundColor(theme.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    if isActive {
                        CyberTag("ON", kanji: "作動")
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(theme.textTertiary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
