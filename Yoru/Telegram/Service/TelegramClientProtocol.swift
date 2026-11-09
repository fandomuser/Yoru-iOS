import Foundation
import Combine

public protocol TelegramClientProtocol: AnyObject {
    /// Stream of incoming authentication state changes
    var authStateStream: AsyncStream<TelegramAuthState> { get }

    /// Stream of incoming chats list updates
    var chatsStream: AsyncStream<[TelegramChat]> { get }

    /// Stream of new incoming or updated messages
    var messageUpdatesStream: AsyncStream<TelegramMessage> { get }

    // MARK: - Lifecycle & Initialization
    func initialize() async throws
    func close() async

    // MARK: - Authentication API
    func setPhoneNumber(_ phoneNumber: String) async throws
    func checkAuthenticationCode(_ code: String) async throws
    func checkAuthenticationPassword(_ password: String) async throws
    func logOut() async throws

    // MARK: - Chats API
    func loadChats(limit: Int) async throws -> [TelegramChat]
    func getChatFolders() async throws -> [ChatFolder]
    func openChat(chatId: Int64) async throws
    func closeChat(chatId: Int64) async throws

    // MARK: - Messaging API
    func getMessages(chatId: Int64, fromMessageId: Int64, limit: Int) async throws -> [TelegramMessage]
    func sendTextMessage(chatId: Int64, text: String, replyToMessageId: Int64?) async throws -> TelegramMessage
    func deleteMessages(chatId: Int64, messageIds: [Int64], revoke: Bool) async throws
    func addReaction(chatId: Int64, messageId: Int64, reaction: String) async throws

    // MARK: - User & Profile API
    func getCurrentUser() async throws -> TelegramUser
    func getUser(userId: Int64) async throws -> TelegramUser
    func searchGlobal(query: String) async throws -> [TelegramChat]
}
