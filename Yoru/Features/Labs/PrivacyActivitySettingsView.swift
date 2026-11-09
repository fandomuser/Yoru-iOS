import SwiftUI

public struct PrivacyActivitySettingsView: View {
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

                    Text("PRIVACY & ACTIVITY")
                        .font(.yoruTitle)
                        .foregroundColor(theme.textPrimary)

                    Spacer()

                    CyberTag("STEALTH", kanji: "隠密")
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 20) {
                        // Stealth Mode Banner
                        CyberCard(cornerCut: 14) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "eye.slash.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(theme.accentSecondary)
                                    Text("STEALTH GHOST MODE")
                                        .font(.yoruCyberBadge)
                                        .foregroundColor(theme.accentSecondary)
                                }

                                Text("Prevents broadcasting typing indicators and allows previewing messages without triggering immediate read receipts.")
                                    .font(.yoruBody)
                                    .foregroundColor(theme.textSecondary)

                                Toggle("Enable Stealth Mode", isOn: Binding(
                                    get: { labs.currentSettings.privacy.stealthModeEnabled },
                                    set: { val in labs.updateSettings { $0.privacy.stealthModeEnabled = val } }
                                ))
                                .tint(theme.accentPrimary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                        // Granular Indicators
                        CyberCard(cornerCut: 12) {
                            VStack(spacing: 16) {
                                Toggle(isOn: Binding(
                                    get: { labs.currentSettings.privacy.suppressTypingIndicator },
                                    set: { val in labs.updateSettings { $0.privacy.suppressTypingIndicator = val } }
                                )) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Suppress Typing Indicator")
                                            .font(.yoruHeadline)
                                            .foregroundColor(theme.textPrimary)
                                        Text("Never broadcast 'typing...' action packet")
                                            .font(.yoruCaption)
                                            .foregroundColor(theme.textSecondary)
                                    }
                                }
                                .tint(theme.accentPrimary)

                                Divider().background(Color.white.opacity(0.1))

                                Toggle(isOn: Binding(
                                    get: { labs.currentSettings.privacy.suppressVoiceRecordIndicator },
                                    set: { val in labs.updateSettings { $0.privacy.suppressVoiceRecordIndicator = val } }
                                )) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Suppress Voice Recording Status")
                                            .font(.yoruHeadline)
                                            .foregroundColor(theme.textPrimary)
                                        Text("Hide audio waveform preparation signals")
                                            .font(.yoruCaption)
                                            .foregroundColor(theme.textSecondary)
                                    }
                                }
                                .tint(theme.accentPrimary)

                                Divider().background(Color.white.opacity(0.1))

                                Toggle(isOn: Binding(
                                    get: { labs.currentSettings.privacy.incognitoChatPreviews },
                                    set: { val in labs.updateSettings { $0.privacy.incognitoChatPreviews = val } }
                                )) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Incognito Chat Previews")
                                            .font(.yoruHeadline)
                                            .foregroundColor(theme.textPrimary)
                                        Text("Peek chat messages without firing openChat read marks")
                                            .font(.yoruCaption)
                                            .foregroundColor(theme.textSecondary)
                                    }
                                }
                                .tint(theme.accentPrimary)
                            }
                        }
                        .padding(.horizontal, 16)

                        // Local Biometrics Section
                        CyberCard(cornerCut: 12) {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Image(systemName: "faceid")
                                        .font(.system(size: 20))
                                        .foregroundColor(theme.onlineStatus)
                                    Text("LOCAL BIOMETRIC LOCK")
                                        .font(.yoruCyberBadge)
                                        .foregroundColor(theme.accentSecondary)
                                }

                                Toggle("Require Face ID / Touch ID", isOn: Binding(
                                    get: { labs.currentSettings.privacy.localBiometricsEnabled },
                                    set: { val in labs.updateSettings { $0.privacy.localBiometricsEnabled = val } }
                                ))
                                .tint(theme.accentPrimary)

                                if labs.currentSettings.privacy.localBiometricsEnabled {
                                    Divider().background(Color.white.opacity(0.1))

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Auto-Lock Inactivity Period")
                                            .font(.yoruSubheadline)
                                            .foregroundColor(theme.textSecondary)

                                        Picker("Timeout", selection: Binding(
                                            get: { labs.currentSettings.privacy.biometricLockTimeout },
                                            set: { val in labs.updateSettings { $0.privacy.biometricLockTimeout = val } }
                                        )) {
                                            ForEach(BiometricLockTimeout.allCases) { timeout in
                                                Text(timeout.displayName).tag(timeout)
                                            }
                                        }
                                        .pickerStyle(.segmented)
                                    }
                                }
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
