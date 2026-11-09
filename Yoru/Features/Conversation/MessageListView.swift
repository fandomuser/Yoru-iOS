import SwiftUI

public struct MessageListView: View {
    let messages: [TelegramMessage]
    let onReactionTap: (TelegramMessage, String) -> Void

    public init(messages: [TelegramMessage], onReactionTap: @escaping (TelegramMessage, String) -> Void) {
        self.messages = messages
        self.onReactionTap = onReactionTap
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(messages) { message in
                        MessageBubbleView(message: message) { emoji in
                            onReactionTap(message, emoji)
                        }
                        .id(message.id)
                    }
                }
                .padding(.vertical, 12)
            }
            .defaultScrollAnchor(.bottom)
            .onChange(of: messages.count) {
                if let last = messages.last {
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}
