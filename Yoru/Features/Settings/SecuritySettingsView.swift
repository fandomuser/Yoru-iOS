import SwiftUI

public struct SecuritySettingsView: View {
    @Environment(\.yoruTheme) private var theme
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

                    Text("SECURITY & PRIVACY")
                        .font(.yoruTitle)
                        .foregroundColor(theme.textPrimary)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 20) {
                        CyberCard(cornerCut: 12) {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Image(systemName: "lock.shield.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(theme.onlineStatus)
                                    Text("ENCRYPTION HARDWARE STATUS")
                                        .font(.yoruCyberBadge)
                                        .foregroundColor(theme.accentSecondary)
                                }

                                Text("All local Telegram SQLite databases are protected with AES-256 keys generated via SecRandom and isolated inside the iOS Keychain Secure Enclave.")
                                    .font(.yoruBody)
                                    .foregroundColor(theme.textSecondary)

                                Divider().background(Color.white.opacity(0.1))

                                HStack {
                                    Text("Keychain Isolation")
                                        .font(.yoruSubheadline)
                                        .foregroundColor(theme.textPrimary)
                                    Spacer()
                                    CyberTag("ACTIVE", kanji: "有効")
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)

                        CyberCard(cornerCut: 12) {
                            VStack(spacing: 14) {
                                settingToggleRow(title: "Passcode & Face ID Lock", subtitle: "Require biometric authentication upon returning to Yoru")
                                Divider().background(Color.white.opacity(0.1))
                                settingToggleRow(title: "Secret Chats MTProto 2.0", subtitle: "End-to-end device encryption without cloud backup")
                                Divider().background(Color.white.opacity(0.1))
                                settingToggleRow(title: "Zero Analytics Policy", subtitle: "Third-party trackers and marketing beacons are permanently disabled")
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

    private func settingToggleRow(title: String, subtitle: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.yoruHeadline)
                    .foregroundColor(theme.textPrimary)
                Text(subtitle)
                    .font(.yoruCaption)
                    .foregroundColor(theme.textSecondary)
            }
            Spacer()
            Image(systemName: "checkmark.shield.fill")
                .foregroundColor(theme.accentSecondary)
        }
    }
}
