import SwiftUI

public struct TranslationSettingsView: View {
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

                    Text("TRANSLATION ENGINE")
                        .font(.yoruTitle)
                        .foregroundColor(theme.textPrimary)

                    Spacer()

                    CyberTag("LINGUA", kanji: "翻訳")
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 20) {
                        // Translation Master Toggle
                        CyberCard(cornerCut: 14) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "character.bubble.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(theme.accentSecondary)
                                    Text("INLINE NEURAL TRANSLATOR")
                                        .font(.yoruCyberBadge)
                                        .foregroundColor(theme.accentSecondary)
                                }

                                Text("Translate foreign language channels and messages directly within the chat bubble with zero data leakage.")
                                    .font(.yoruBody)
                                    .foregroundColor(theme.textSecondary)

                                Toggle("Enable Translation", isOn: Binding(
                                    get: { labs.currentSettings.translation.translationEnabled },
                                    set: { val in labs.updateSettings { $0.translation.translationEnabled = val } }
                                ))
                                .tint(theme.accentPrimary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                        // Engine Provider
                        CyberCard(cornerCut: 12) {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("TRANSLATION BACKEND PROVIDER")
                                    .font(.yoruCyberBadge)
                                    .foregroundColor(theme.accentSecondary)

                                Picker("Provider", selection: Binding(
                                    get: { labs.currentSettings.translation.provider },
                                    set: { val in labs.updateSettings { $0.translation.provider = val } }
                                )) {
                                    ForEach(TranslationProvider.allCases) { provider in
                                        Text(provider.displayName).tag(provider)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(theme.accentPrimary)

                                Divider().background(Color.white.opacity(0.1))

                                Toggle("Auto-Translate Foreign Channels", isOn: Binding(
                                    get: { labs.currentSettings.translation.autoTranslateChannels },
                                    set: { val in labs.updateSettings { $0.translation.autoTranslateChannels = val } }
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
