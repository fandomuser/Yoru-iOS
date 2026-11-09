import SwiftUI

public struct AIToolsSettingsView: View {
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

                    Text("AI TOOLS & AGENTS")
                        .font(.yoruTitle)
                        .foregroundColor(theme.textPrimary)

                    Spacer()

                    CyberTag("NEURAL", kanji: "知能")
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 20) {
                        // AI Master Toggle
                        CyberCard(cornerCut: 14) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "brain.head.profile")
                                        .font(.system(size: 22))
                                        .foregroundColor(theme.accentPrimary)
                                    Text("ANIME ASSISTANT ENGINE")
                                        .font(.yoruCyberBadge)
                                        .foregroundColor(theme.accentSecondary)
                                }

                                Text("Empower your chats with smart contextual reply suggestions, instant thread summaries, and an anime persona assistant.")
                                    .font(.yoruBody)
                                    .foregroundColor(theme.textSecondary)

                                Toggle("Enable AI Intelligence", isOn: Binding(
                                    get: { labs.currentSettings.ai.aiEnabled },
                                    set: { val in labs.updateSettings { $0.ai.aiEnabled = val } }
                                ))
                                .tint(theme.accentPrimary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                        // AI Features
                        CyberCard(cornerCut: 12) {
                            VStack(spacing: 16) {
                                Picker("Inference Engine", selection: Binding(
                                    get: { labs.currentSettings.ai.provider },
                                    set: { val in labs.updateSettings { $0.ai.provider = val } }
                                )) {
                                    ForEach(AIProvider.allCases) { provider in
                                        Text(provider.displayName).tag(provider)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(theme.accentPrimary)

                                Divider().background(Color.white.opacity(0.1))

                                Toggle("Smart Tactical Replies", isOn: Binding(
                                    get: { labs.currentSettings.ai.smartRepliesEnabled },
                                    set: { val in labs.updateSettings { $0.ai.smartRepliesEnabled = val } }
                                ))
                                .tint(theme.accentPrimary)

                                Divider().background(Color.white.opacity(0.1))

                                Toggle("Long Channel Summary TL;DR", isOn: Binding(
                                    get: { labs.currentSettings.ai.chatSummarizationEnabled },
                                    set: { val in labs.updateSettings { $0.ai.chatSummarizationEnabled = val } }
                                ))
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
