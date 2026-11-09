import SwiftUI

@Observable
public final class ConversationViewModel {
    public let chat: TelegramChat
    public var messages: [TelegramMessage] = []
    public var inputText: String = ""
    public var isLoading: Bool = false

    private let telegramService: TelegramService
    private var updatesTask: Task<Void, Never>?

    public init(chat: TelegramChat, telegramService: TelegramService = .shared) {
        self.chat = chat
        self.telegramService = telegramService
    }

    deinit {
        updatesTask?.cancel()
    }

    public func loadMessages() {
        isLoading = true
        Task {
            do {
                let initial = try await telegramService.loadMessages(chatId: chat.id)
                await MainActor.run {
                    self.messages = initial
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }

        listenToIncomingMessages()
    }

    private func listenToIncomingMessages() {
        updatesTask = Task { [weak self] in
            guard let self = self else { return }
            for await update in self.telegramService.client.messageUpdatesStream {
                if update.chatId == self.chat.id {
                    await MainActor.run {
                        if let index = self.messages.firstIndex(where: { $0.id == update.id }) {
                            self.messages[index] = update
                        } else {
                            self.messages.append(update)
                        }
                    }
                }
            }
        }
    }

    public func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        inputText = ""

        Task {
            do {
                let sent = try await telegramService.sendTextMessage(chatId: chat.id, text: text)
                await MainActor.run {
                    if !self.messages.contains(where: { $0.id == sent.id }) {
                        self.messages.append(sent)
                    }
                }
            } catch {
                // Handle delivery failure
            }
        }
    }

    public func addReaction(to message: TelegramMessage, emoji: String) {
        Task {
            try? await telegramService.addReaction(chatId: chat.id, messageId: message.id, emoji: emoji)
        }
    }
}
