import SwiftUI

public struct MessageHistorySettingsView: View {
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

                    Text("MESSAGE HISTORY")
                        .font(.yoruTitle)
                        .foregroundColor(theme.textPrimary)

                    Spacer()

                    CyberTag("VAULT", kanji: "保管庫")
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 20) {
                        // Anti-Recall Card
                        CyberCard(cornerCut: 14) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .font(.system(size: 22))
                                        .foregroundColor(theme.accentPrimary)
                                    Text("ANTI-RECALL ARCHIVE")
                                        .font(.yoruCyberBadge)
                                        .foregroundColor(theme.accentSecondary)
                                }

                                Text("Preserve incoming transmissions locally when deleted remotely by the sender. Encrypted in your local iOS Keychain storage.")
                                    .font(.yoruBody)
                                    .foregroundColor(theme.textSecondary)

                                Toggle("Enable Anti-Recall Vault", isOn: Binding(
                                    get: { labs.currentSettings.history.antiRecallEnabled },
                                    set: { val in labs.updateSettings { $0.history.antiRecallEnabled = val } }
                                ))
                                .tint(theme.accentPrimary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                        // Settings Options
                        CyberCard(cornerCut: 12) {
                            VStack(spacing: 16) {
                                Toggle(isOn: Binding(
                                    get: { labs.currentSettings.history.markDeletedMessages },
                                    set: { val in labs.updateSettings { $0.history.markDeletedMessages = val } }
                                )) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Mark Deleted Transmissions")
                                            .font(.yoruHeadline)
                                            .foregroundColor(theme.textPrimary)
                                        Text("Attach cyber red [DELETED // 削除済] badge")
                                            .font(.yoruCaption)
                                            .foregroundColor(theme.textSecondary)
                                    }
                                }
                                .tint(theme.accentPrimary)

                                Divider().background(Color.white.opacity(0.1))

                                Toggle(isOn: Binding(
                                    get: { labs.currentSettings.history.trackEditHistory },
                                    set: { val in labs.updateSettings { $0.history.trackEditHistory = val } }
                                )) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Track Revision History")
                                            .font(.yoruHeadline)
                                            .foregroundColor(theme.textPrimary)
                                        Text("Store previous versions of edited messages")
                                            .font(.yoruCaption)
                                            .foregroundColor(theme.textSecondary)
                                    }
                                }
                                .tint(theme.accentPrimary)

                                Divider().background(Color.white.opacity(0.1))

                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Retention Window")
                                            .font(.yoruHeadline)
                                            .foregroundColor(theme.textPrimary)
                                        Spacer()
                                        Text("\(labs.currentSettings.history.historyRetentionDays) Days")
                                            .font(.yoruCaption)
                                            .foregroundColor(theme.accentSecondary)
                                    }

                                    Slider(
                                        value: Binding(
                                            get: { Double(labs.currentSettings.history.historyRetentionDays) },
                                            set: { val in labs.updateSettings { $0.history.historyRetentionDays = Int(val) } }
                                        ),
                                        in: 7...90,
                                        step: 1
                                    )
                                    .tint(theme.accentPrimary)
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
