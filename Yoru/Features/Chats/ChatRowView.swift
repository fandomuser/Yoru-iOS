import SwiftUI

public struct ChatRowView: View {
    @Environment(\.yoruTheme) private var theme
    let chat: TelegramChat

    public init(chat: TelegramChat) {
        self.chat = chat
    }

    private var labs: YoruLabsManager {
        YoruLabsManager.shared
    }

    public var body: some View {
        HStack(spacing: 14) {
            // Avatar
            YoruAvatarView(
                name: chat.title,
                avatarUrl: chat.avatarUrl,
                size: 54,
                isOnline: isChatOnline
            )

            // Details
            VStack(alignment: .leading, spacing: 4) {
                // Top row: Title + Pin + Timestamp
                HStack(alignment: .center, spacing: 4) {
                    Text(labs.maskIfStreamer(chat.title, type: .chatTitle))
                        .font(.yoruHeadline)
                        .foregroundColor(theme.textPrimary)
                        .lineLimit(1)

                    if chat.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 11))
                            .foregroundColor(theme.accentSecondary)
                    }

                    Spacer()

                    if let lastMsg = chat.lastMessage {
                        Text(lastMsg.date.yoruChatTimestamp())
                            .font(.system(size: 12, weight: .regular, design: .monospaced))
                            .foregroundColor(chat.unreadCount > 0 ? theme.accentPrimary : theme.textTertiary)
                    }
                }

                // Bottom row: Last message preview + Unread badge
                HStack(alignment: .center, spacing: 6) {
                    messageSnippetView
                        .lineLimit(1)

                    Spacer()

                    if chat.isMuted {
                        Image(systemName: "bell.slash.fill")
                            .font(.system(size: 11))
                            .foregroundColor(theme.textTertiary)
                    }

                    UnreadBadge(count: chat.unreadCount, isMuted: chat.isMuted)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            chat.isPinned ? theme.glassSurface.opacity(0.35) : Color.clear
        )
    }

    @ViewBuilder
    private var messageSnippetView: some View {
        if let draft = chat.draftMessage, !draft.isEmpty {
            HStack(spacing: 4) {
                Text("Draft:")
                    .font(.yoruSubheadline)
                    .foregroundColor(theme.destructive)
                Text(draft)
                    .font(.yoruSubheadline)
                    .foregroundColor(theme.textSecondary)
            }
        } else if let msg = chat.lastMessage {
            HStack(spacing: 4) {
                if msg.isOutgoing {
                    deliveryIndicator(msg.deliveryState)
                }

                switch msg.content {
                case .text(let text):
                    Text(text)
                        .font(.yoruSubheadline)
                        .foregroundColor(theme.textSecondary)
                case .photo:
                    HStack(spacing: 4) {
                        Image(systemName: "photo")
                            .font(.system(size: 12))
                        Text("Photo transmission")
                            .font(.yoruSubheadline)
                    }
                    .foregroundColor(theme.accentSecondary)
                case .voice:
                    HStack(spacing: 4) {
                        Image(systemName: "waveform")
                            .font(.system(size: 12))
                        Text("Voice note")
                            .font(.yoruSubheadline)
                    }
                    .foregroundColor(theme.accentSecondary)
                default:
                    Text("Encrypted content")
                        .font(.yoruSubheadline)
                        .foregroundColor(theme.textTertiary)
                }
            }
        } else {
            Text("No messages yet")
                .font(.yoruSubheadline)
                .foregroundColor(theme.textTertiary)
        }
    }

    @ViewBuilder
    private func deliveryIndicator(_ state: MessageDeliveryState) -> some View {
        switch state {
        case .sent:
            Image(systemName: "checkmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(theme.textTertiary)
        case .read:
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(theme.accentSecondary)
        default:
            EmptyView()
        }
    }

    private var isChatOnline: Bool {
        if case .private = chat.type {
            return true
        }
        return false
    }
}
