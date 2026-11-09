import Foundation
import Combine

public final class MockTelegramClient: TelegramClientProtocol {
    private var authContinuation: AsyncStream<TelegramAuthState>.Continuation?
    private var chatsContinuation: AsyncStream<[TelegramChat]>.Continuation?
    private var messageContinuation: AsyncStream<TelegramMessage>.Continuation?

    private var currentAuthState: TelegramAuthState = .waitingForPhoneNumber
    private var chats: [TelegramChat] = []
    private var messagesStore: [Int64: [TelegramMessage]] = [:]

    public lazy var authStateStream: AsyncStream<TelegramAuthState> = {
        AsyncStream { continuation in
            self.authContinuation = continuation
            continuation.yield(self.currentAuthState)
        }
    }()

    public lazy var chatsStream: AsyncStream<[TelegramChat]> = {
        AsyncStream { continuation in
            self.chatsContinuation = continuation
            continuation.yield(self.chats)
        }
    }()

    public lazy var messageUpdatesStream: AsyncStream<TelegramMessage> = {
        AsyncStream { continuation in
            self.messageContinuation = continuation
        }
    }()

    public init(initialState: TelegramAuthState = .ready(user: MockDataGenerator.currentUser)) {
        self.currentAuthState = initialState
        self.chats = MockDataGenerator.sampleChats()
        for chat in self.chats {
            self.messagesStore[chat.id] = MockDataGenerator.sampleMessages(for: chat.id)
        }
    }

    public func initialize() async throws {
        // Yield initial state
        authContinuation?.yield(currentAuthState)
        chatsContinuation?.yield(chats)
    }

    public func close() async {
        authContinuation?.finish()
        chatsContinuation?.finish()
        messageContinuation?.finish()
    }

    // MARK: - Auth API
    public func setPhoneNumber(_ phoneNumber: String) async throws {
        try await Task.sleep(nanoseconds: 600_000_000)
        currentAuthState = .waitingForCode(type: .telegramApp, nextCodeType: .sms, timeout: 60)
        authContinuation?.yield(currentAuthState)
    }

    public func checkAuthenticationCode(_ code: String) async throws {
        try await Task.sleep(nanoseconds: 600_000_000)
        // If code ends in 2, simulate 2FA requirement
        if code.hasSuffix("2") {
            currentAuthState = .waitingForPassword(hint: "Anime secret passcode", hasRecovery: true)
        } else {
            currentAuthState = .ready(user: MockDataGenerator.currentUser)
        }
        authContinuation?.yield(currentAuthState)
    }

    public func checkAuthenticationPassword(_ password: String) async throws {
        try await Task.sleep(nanoseconds: 600_000_000)
        currentAuthState = .ready(user: MockDataGenerator.currentUser)
        authContinuation?.yield(currentAuthState)
    }

    public func logOut() async throws {
        currentAuthState = .waitingForPhoneNumber
        authContinuation?.yield(currentAuthState)
    }

    // MARK: - Chats API
    public func loadChats(limit: Int) async throws -> [TelegramChat] {
        return chats
    }

    public func getChatFolders() async throws -> [ChatFolder] {
        return MockDataGenerator.sampleFolders
    }

    public func openChat(chatId: Int64) async throws {}
    public func closeChat(chatId: Int64) async throws {}

    // MARK: - Messaging API
    public func getMessages(chatId: Int64, fromMessageId: Int64, limit: Int) async throws -> [TelegramMessage] {
        return messagesStore[chatId] ?? []
    }

    public func sendTextMessage(chatId: Int64, text: String, replyToMessageId: Int64?) async throws -> TelegramMessage {
        let newMsg = TelegramMessage(
            id: Int64(Date().timeIntervalSince1970 * 1000),
            chatId: chatId,
            senderId: MockDataGenerator.currentUser.id,
            senderName: MockDataGenerator.currentUser.fullName,
            isOutgoing: true,
            date: Date(),
            content: .text(text),
            replyToMessageId: replyToMessageId,
            deliveryState: .sent
        )

        var list = messagesStore[chatId] ?? []
        list.append(newMsg)
        messagesStore[chatId] = list

        messageContinuation?.yield(newMsg)
        return newMsg
    }

    public func deleteMessages(chatId: Int64, messageIds: [Int64], revoke: Bool) async throws {
        if var list = messagesStore[chatId] {
            list.removeAll { messageIds.contains($0.id) }
            messagesStore[chatId] = list
        }
    }

    public func addReaction(chatId: Int64, messageId: Int64, reaction: String) async throws {
        if var list = messagesStore[chatId], let index = list.firstIndex(where: { $0.id == messageId }) {
            var reactions = list[index].reactions
            if let rIndex = reactions.firstIndex(where: { $0.emoji == reaction }) {
                let current = reactions[rIndex]
                reactions[rIndex] = MessageReaction(emoji: reaction, count: current.count + 1, isChosen: true)
            } else {
                reactions.append(MessageReaction(emoji: reaction, count: 1, isChosen: true))
            }
            let updated = TelegramMessage(
                id: list[index].id,
                chatId: list[index].chatId,
                senderId: list[index].senderId,
                senderName: list[index].senderName,
                isOutgoing: list[index].isOutgoing,
                date: list[index].date,
                editDate: list[index].editDate,
                content: list[index].content,
                replyToMessageId: list[index].replyToMessageId,
                replyToSnippet: list[index].replyToSnippet,
                forwardInfo: list[index].forwardInfo,
                reactions: reactions,
                deliveryState: list[index].deliveryState,
                isPinned: list[index].isPinned
            )
            list[index] = updated
            messagesStore[chatId] = list
            messageContinuation?.yield(updated)
        }
    }

    // MARK: - User & Search API
    public func getCurrentUser() async throws -> TelegramUser {
        return MockDataGenerator.currentUser
    }

    public func getUser(userId: Int64) async throws -> TelegramUser {
        return MockDataGenerator.sampleUsers.first { $0.id == userId } ?? MockDataGenerator.currentUser
    }

    public func searchGlobal(query: String) async throws -> [TelegramChat] {
        guard !query.isEmpty else { return [] }
        return chats.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }
}
