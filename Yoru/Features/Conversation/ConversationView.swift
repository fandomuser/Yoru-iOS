import SwiftUI

public struct ConversationView: View {
    @Environment(\.yoruTheme) private var theme
    @State private var viewModel: ConversationViewModel
    private let onBack: () -> Void
    private let onInfoTap: () -> Void

    @State private var showSendConfirmation: Bool = false
    @State private var pendingSendAction: (() -> Void)?

    public init(chat: TelegramChat, onBack: @escaping () -> Void, onInfoTap: @escaping () -> Void) {
        _viewModel = State(initialValue: ConversationViewModel(chat: chat))
        self.onBack = onBack
        self.onInfoTap = onInfoTap
    }

    private var labs: YoruLabsManager {
        YoruLabsManager.shared
    }

    public var body: some View {
        ZStack {
            theme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                ConversationHeaderView(
                    chat: viewModel.chat,
                    onBack: onBack,
                    onInfoTap: onInfoTap
                )

                // Message Timeline
                if viewModel.messages.isEmpty && !viewModel.isLoading {
                    Spacer()
                    EmptyStateView(
                        title: "No Signal",
                        subtitle: "Transmit the first encrypted packet to establish communication.",
                        kanji: "信",
                        systemIcon: "bolt.horizontal.fill"
                    )
                    Spacer()
                } else {
                    MessageListView(
                        messages: viewModel.messages,
                        onReactionTap: { message, emoji in
                            viewModel.addReaction(to: message, emoji: emoji)
                        }
                    )
                }

                // Chat Input Console
                ChatInputField(
                    text: $viewModel.inputText,
                    onSend: {
                        attemptSendMessage()
                    },
                    onAttachmentTap: {},
                    onVoiceRecordTap: {}
                )
            }
        }
        .onAppear {
            viewModel.loadMessages()
        }
        .alert("TRANSMISSION CONFIRMATION // 送信確認", isPresented: $showSendConfirmation) {
            Button("Transmit", role: .none) {
                pendingSendAction?()
                pendingSendAction = nil
            }
            Button("Cancel", role: .cancel) {
                pendingSendAction = nil
            }
        } message: {
            Text("You are transmitting a broadcast packet to '\(viewModel.chat.title)'. Are you sure you wish to proceed?")
        }
        .navigationBarBackButtonHidden()
    }

    private func attemptSendMessage() {
        let needsConfirmation: Bool
        switch viewModel.chat.type {
        case .supergroup(_, let isChannel):
            needsConfirmation = isChannel ? labs.currentSettings.chat.sendConfirmationChannel : labs.currentSettings.chat.sendConfirmationSupergroup
        case .basicGroup:
            needsConfirmation = labs.currentSettings.chat.sendConfirmationSupergroup
        default:
            needsConfirmation = false
        }

        if needsConfirmation {
            pendingSendAction = {
                viewModel.sendMessage()
            }
            showSendConfirmation = true
        } else {
            viewModel.sendMessage()
        }
    }
}
