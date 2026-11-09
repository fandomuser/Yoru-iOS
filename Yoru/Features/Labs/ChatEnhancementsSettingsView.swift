import SwiftUI

public struct ChatEnhancementsSettingsView: View {
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

                    Text("CHAT ENHANCEMENTS")
                        .font(.yoruTitle)
                        .foregroundColor(theme.textPrimary)

                    Spacer()

                    CyberTag("TACTICAL", kanji: "通信")
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 20) {
                        // Send Confirmations Card
                        CyberCard(cornerCut: 14) {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("TRANSMISSION SAFETY GATES")
                                    .font(.yoruCyberBadge)
                                    .foregroundColor(theme.accentSecondary)

                                Toggle("Confirm Before Sending in Channels", isOn: Binding(
                                    get: { labs.currentSettings.chat.sendConfirmationChannel },
                                    set: { val in labs.updateSettings { $0.chat.sendConfirmationChannel = val } }
                                ))
                                .tint(theme.accentPrimary)

                                Divider().background(Color.white.opacity(0.1))

                                Toggle("Confirm in Public Supergroups", isOn: Binding(
                                    get: { labs.currentSettings.chat.sendConfirmationSupergroup },
                                    set: { val in labs.updateSettings { $0.chat.sendConfirmationSupergroup = val } }
                                ))
                                .tint(theme.accentPrimary)

                                Divider().background(Color.white.opacity(0.1))

                                Toggle("Confirm Before Voice Message Release", isOn: Binding(
                                    get: { labs.currentSettings.chat.sendConfirmationVoice },
                                    set: { val in labs.updateSettings { $0.chat.sendConfirmationVoice = val } }
                                ))
                                .tint(theme.accentPrimary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                        // Double Tap Action
                        CyberCard(cornerCut: 12) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("DOUBLE-TAP QUICK ACTION")
                                    .font(.yoruCyberBadge)
                                    .foregroundColor(theme.accentSecondary)

                                Picker("Action", selection: Binding(
                                    get: { labs.currentSettings.chat.doubleTapAction },
                                    set: { val in labs.updateSettings { $0.chat.doubleTapAction = val } }
                                )) {
                                    ForEach(QuickAction.allCases) { action in
                                        Text(action.displayName).tag(action)
                                    }
                                }
                                .pickerStyle(.menu)
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
