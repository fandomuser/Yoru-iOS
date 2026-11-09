import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct MessageBubbleView: View {
    @Environment(\.yoruTheme) private var theme
    private let message: TelegramMessage
    private let onReactionTap: (String) -> Void
    private let onReplyTap: (TelegramMessage) -> Void
    private let onDeleteTap: (TelegramMessage) -> Void

    @State private var isSpoilerRevealed: Bool = false
    @State private var translatedText: String? = nil
    @State private var isTranslating: Bool = false

    public init(
        message: TelegramMessage,
        onReactionTap: @escaping (String) -> Void = { _ in },
        onReplyTap: @escaping (TelegramMessage) -> Void = { _ in },
        onDeleteTap: @escaping (TelegramMessage) -> Void = { _ in }
    ) {
        self.message = message
        self.onReactionTap = onReactionTap
        self.onReplyTap = onReplyTap
        self.onDeleteTap = onDeleteTap
    }

    private var labs: YoruLabsManager {
        YoruLabsManager.shared
    }

    private var filterResult: MessageFilterResult {
        if case .text(let txt) = message.content {
            return labs.filterMessageText(txt)
        }
        return .allowed
    }

    private var bubbleCornerRadius: CGFloat {
        CGFloat(labs.currentSettings.appearance.bubbleCornerRadius)
    }

    public var body: some View {
        if case .hidden = filterResult {
            // Drop completely (silent filter)
            EmptyView()
        } else {
            HStack(alignment: .bottom, spacing: 8) {
                if message.isOutgoing {
                    Spacer(minLength: 48)
                }

                VStack(alignment: message.isOutgoing ? .trailing : .leading, spacing: 4) {
                    // Anti-Recall Deleted Badge
                    if message.isDeletedLocally {
                        HStack(spacing: 4) {
                            Image(systemName: "trash.circle.fill")
                                .font(.system(size: 11))
                            Text("DELETED TRANSMISSION // 削除済")
                                .font(.yoruCyberBadge)
                        }
                        .foregroundColor(theme.destructive)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(theme.destructive.opacity(0.15))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(theme.destructive.opacity(0.4), lineWidth: 1))
                    }

                    // Reply Quote Preview
                    if let replySnippet = message.replyToSnippet {
                        HStack(spacing: 6) {
                            Rectangle()
                                .fill(theme.accentSecondary)
                                .frame(width: 3)
                            Text(replySnippet)
                                .font(.yoruCaption)
                                .foregroundColor(theme.textSecondary)
                                .lineLimit(1)
                        }
                        .padding(6)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(6)
                    }

                    // Collapsed Filter Warning Bar
                    if case .collapsed(let reason) = filterResult, !isSpoilerRevealed {
                        Button(action: { isSpoilerRevealed = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.shield.fill")
                                    .font(.system(size: 13))
                                Text("Filtered: \(reason) (Tap to view)")
                                    .font(.yoruCaption)
                            }
                            .foregroundColor(theme.warning)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(theme.warning.opacity(0.12))
                            .cornerRadius(bubbleCornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: bubbleCornerRadius)
                                    .stroke(theme.warning.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        // Main Bubble
                        VStack(alignment: .leading, spacing: 6) {
                            contentView
                                .blur(radius: isBlurred ? 12 : 0)
                                .overlay(
                                    isBlurred ?
                                    Button(action: { isSpoilerRevealed = true }) {
                                        Text("SPOILER // TAP TO REVEAL")
                                            .font(.yoruCyberBadge)
                                            .foregroundColor(theme.accentSecondary)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(theme.backgroundPrimary.opacity(0.85))
                                            .cornerRadius(8)
                                    } : nil
                                )

                            // Inline Translation Display
                            if let translated = translatedText {
                                Divider().background(Color.white.opacity(0.1))
                                HStack(alignment: .top, spacing: 4) {
                                    Image(systemName: "character.bubble.fill")
                                        .font(.system(size: 11))
                                        .foregroundColor(theme.accentSecondary)
                                    Text(translated)
                                        .font(.yoruBody)
                                        .foregroundColor(theme.accentSecondary)
                                }
                            }

                            // Metadata row
                            HStack(spacing: 4) {
                                Spacer()

                                Text(message.date.yoruMessageTime())
                                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                                    .foregroundColor(metadataColor)

                                if message.isOutgoing {
                                    deliveryIcon
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(bubbleBackground)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: bubbleCornerRadius,
                                style: .continuous
                            )
                        )
                        .overlay(bubbleBorder)
                        .contentShape(RoundedRectangle(cornerRadius: bubbleCornerRadius))
                        .contextMenu {
                            contextMenuContent
                        }
                        .onTapGesture(count: 2) {
                            handleDoubleTap()
                        }
                    }

                    // Reactions Row
                    if !labs.currentSettings.appearance.hideQuickReactionsBar && !message.reactions.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(message.reactions) { reaction in
                                Button(action: { onReactionTap(reaction.emoji) }) {
                                    HStack(spacing: 4) {
                                        Text(reaction.emoji)
                                            .font(.system(size: 13))
                                        Text("\(reaction.count)")
                                            .font(.yoruCyberBadge)
                                            .foregroundColor(reaction.isChosen ? theme.accentPrimary : theme.textSecondary)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(reaction.isChosen ? theme.accentPrimary.opacity(0.2) : theme.glassSurface.opacity(0.8))
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(
                                                reaction.isChosen ? theme.accentPrimary : Color.white.opacity(0.1),
                                                lineWidth: 1
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 2)
                    }
                }

                if !message.isOutgoing {
                    Spacer(minLength: 48)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 2)
        }
    }

    private var isBlurred: Bool {
        if case .blurred = filterResult, !isSpoilerRevealed {
            return true
        }
        return false
    }

    private func handleDoubleTap() {
        switch labs.currentSettings.chat.doubleTapAction {
        case .reactHeart:
            onReactionTap("❤️")
        case .reactFire:
            onReactionTap("🔥")
        case .reactLightning:
            onReactionTap("⚡")
        case .reply:
            onReplyTap(message)
        case .copy:
            copyMessageText()
        case .translate:
            triggerTranslation()
        }
    }

    private func copyMessageText() {
        if case .text(let txt) = message.content {
            #if canImport(UIKit)
            UIPasteboard.general.string = txt
            #endif
        }
    }

    private func triggerTranslation() {
        if case .text(let txt) = message.content {
            isTranslating = true
            // Local simulation / provider hook
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.translatedText = "「日本語訳」\(txt)"
                self.isTranslating = false
            }
        }
    }

    @ViewBuilder
    private var contextMenuContent: some View {
        Button {
            copyMessageText()
        } label: {
            Label("Copy Text", systemImage: "doc.on.doc")
        }

        Button {
            onReplyTap(message)
        } label: {
            Label("Reply", systemImage: "arrowshape.turn.up.left")
        }

        Button {
            triggerTranslation()
        } label: {
            Label("Translate with Yoru Labs", systemImage: "character.bubble")
        }

        Menu("Add Reaction") {
            Button("⚡ Shock") { onReactionTap("⚡") }
            Button("🔥 Fire") { onReactionTap("🔥") }
            Button("❤️ Heart") { onReactionTap("❤️") }
            Button("🌸 Sakura") { onReactionTap("🌸") }
        }

        Divider()

        Button(role: .destructive) {
            onDeleteTap(message)
        } label: {
            Label("Delete Message", systemImage: "trash")
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch message.content {
        case .text(let text):
            Text(text)
                .font(.yoruBody)
                .foregroundColor(message.isOutgoing ? theme.bubbleOutgoingText : theme.bubbleIncomingText)

        case .photo(_, let caption, _, _):
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [theme.accentPrimary.opacity(0.4), theme.accentSecondary.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 180)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo.artframe")
                                .font(.system(size: 36))
                                .foregroundColor(theme.accentSecondary)
                            Text("ANIME HOLOGRAM TRANSMISSION")
                                .font(.yoruCyberBadge)
                                .foregroundColor(theme.textPrimary)
                        }
                    )

                if let caption = caption {
                    Text(caption)
                        .font(.yoruBody)
                        .foregroundColor(message.isOutgoing ? theme.bubbleOutgoingText : theme.bubbleIncomingText)
                }
            }

        case .voice(_, let duration, _):
            HStack(spacing: 12) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(message.isOutgoing ? theme.accentSecondary : theme.accentPrimary)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 2) {
                        ForEach(0..<18) { index in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(message.isOutgoing ? theme.bubbleOutgoingText.opacity(0.8) : theme.accentSecondary)
                                .frame(width: 3, height: CGFloat(index % 4 == 0 ? 18 : (index % 3 == 0 ? 12 : 6)))
                        }
                    }
                    Text("0:0\(duration)")
                        .font(.yoruCaption)
                        .foregroundColor(metadataColor)
                }
            }
            .padding(.vertical, 4)

        default:
            Text("Encrypted Cyber Transmission")
                .font(.yoruBody)
                .foregroundColor(theme.textSecondary)
        }
    }

    @ViewBuilder
    private var bubbleBackground: some View {
        if message.isOutgoing {
            LinearGradient(
                colors: [theme.bubbleOutgoing, theme.bubbleOutgoing.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            theme.bubbleIncoming.opacity(0.92)
        }
    }

    @ViewBuilder
    private var bubbleBorder: some View {
        RoundedRectangle(cornerRadius: bubbleCornerRadius, style: .continuous)
            .stroke(
                message.isDeletedLocally ? theme.destructive.opacity(0.5) : (message.isOutgoing ? Color.white.opacity(0.18) : theme.accentPrimary.opacity(0.2)),
                lineWidth: message.isDeletedLocally ? 1.5 : 1
            )
    }

    private var metadataColor: Color {
        message.isOutgoing ? theme.bubbleOutgoingText.opacity(0.7) : theme.textTertiary
    }

    @ViewBuilder
    private var deliveryIcon: some View {
        switch message.deliveryState {
        case .sending:
            ProgressView()
                .scaleEffect(0.5)
                .frame(width: 12, height: 12)
        case .sent:
            Image(systemName: "checkmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(metadataColor)
        case .read:
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(theme.accentSecondary)
        case .error:
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(theme.destructive)
        }
    }
}
