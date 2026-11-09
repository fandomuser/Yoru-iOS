import SwiftUI

public struct ConversationHeaderView: View {
    @Environment(\.yoruTheme) private var theme
    let chat: TelegramChat
    let onBack: () -> Void
    let onInfoTap: () -> Void

    public init(chat: TelegramChat, onBack: @escaping () -> Void, onInfoTap: @escaping () -> Void) {
        self.chat = chat
        self.onBack = onBack
        self.onInfoTap = onInfoTap
    }

    public var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(theme.accentSecondary)
                    .frame(width: 32, height: 32)
            }

            Button(action: onInfoTap) {
                HStack(spacing: 10) {
                    YoruAvatarView(
                        name: chat.title,
                        avatarUrl: chat.avatarUrl,
                        size: 38,
                        isOnline: true,
                        showBorder: false
                    )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(chat.title)
                            .font(.yoruHeadline)
                            .foregroundColor(theme.textPrimary)
                            .lineLimit(1)

                        HStack(spacing: 4) {
                            Circle()
                                .fill(theme.onlineStatus)
                                .frame(width: 6, height: 6)
                            Text("Online • Connected to Sector")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(theme.accentSecondary)
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer()

            // Call / Options Button
            CyberIconButton(icon: "ellipsis", size: 36) {
                onInfoTap()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            theme.backgroundSecondary.opacity(0.88)
                .background(.ultraThinMaterial)
        )
        .overlay(
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
            }
        )
    }
}
