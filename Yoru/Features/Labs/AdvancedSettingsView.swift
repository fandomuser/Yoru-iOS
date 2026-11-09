import SwiftUI

public struct AdvancedSettingsView: View {
    @Environment(\.yoruTheme) private var theme
    private let labs = YoruLabsManager.shared
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

                    Text("ADVANCED & STREAMER")
                        .font(.yoruTitle)
                        .foregroundColor(theme.textPrimary)

                    Spacer()

                    CyberTag("ROOT", kanji: "高度")
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 20) {
                        // Streamer Mode Card
                        CyberCard(cornerCut: 14) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "video.badge.waveform.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(theme.onlineStatus)
                                    Text("GLOBAL STREAMER MODE")
                                        .font(.yoruCyberBadge)
                                        .foregroundColor(theme.accentSecondary)
                                }

                                Text("Instantly mask all usernames, phone numbers, and chat titles with cyberpunk censorship tags to prevent accidental dox leaks on stream or screen recording.")
                                    .font(.yoruBody)
                                    .foregroundColor(theme.textSecondary)

                                Toggle("Enable Streamer Mode", isOn: Binding(
                                    get: { labs.currentSettings.advanced.streamerModeEnabled },
                                    set: { val in labs.updateSettings { $0.advanced.streamerModeEnabled = val } }
                                ))
                                .tint(theme.onlineStatus)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                        // Advanced Tweaks
                        CyberCard(cornerCut: 12) {
                            VStack(spacing: 16) {
                                Toggle(isOn: Binding(
                                    get: { labs.currentSettings.advanced.showDebugTDLibConsole },
                                    set: { val in labs.updateSettings { $0.advanced.showDebugTDLibConsole = val } }
                                )) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("TDLib JSON Packet Console")
                                            .font(.yoruHeadline)
                                            .foregroundColor(theme.textPrimary)
                                        Text("Stream raw TDLib send/receive events (Developer)")
                                            .font(.yoruCaption)
                                            .foregroundColor(theme.textSecondary)
                                    }
                                }
                                .tint(theme.accentPrimary)

                                Divider().background(Color.white.opacity(0.1))

                                Toggle(isOn: Binding(
                                    get: { labs.currentSettings.advanced.disableAnimations },
                                    set: { val in labs.updateSettings { $0.advanced.disableAnimations = val } }
                                )) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Reduced Motion Mode")
                                            .font(.yoruHeadline)
                                            .foregroundColor(theme.textPrimary)
                                        Text("Disable springs and neon pulses for accessibility")
                                            .font(.yoruCaption)
                                            .foregroundColor(theme.textSecondary)
                                    }
                                }
                                .tint(theme.accentPrimary)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}
