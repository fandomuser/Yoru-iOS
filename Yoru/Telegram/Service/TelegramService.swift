import Foundation
import Combine
import SwiftUI
import Observation

public enum TelegramServiceMode {
    case production
    case preview
    case custom(TelegramClientProtocol)
}

@Observable
public final class TelegramService {
    // Production instance by default — connects to real TDLib network stack
    public static let shared = TelegramService(mode: .production)

    // Preview instance explicitly for SwiftUI Canvas and deterministic offline dev
    public static let preview = TelegramService(mode: .preview)

    public private(set) var authState: TelegramAuthState = .uninitialized
    public private(set) var chats: [TelegramChat] = []
    public private(set) var chatFolders: [ChatFolder] = []
    public private(set) var currentUser: TelegramUser?
    public private(set) var isConnected: Bool = false
    public var lastError: String?

    public let mode: TelegramServiceMode
    public let client: TelegramClientProtocol

    private var tasks: [Task<Void, Never>] = []

    public init(mode: TelegramServiceMode = .production) {
        self.mode = mode
        switch mode {
        case .production:
            self.client = TDLibJsonClient()
        case .preview:
            self.client = MockTelegramClient()
        case .custom(let customClient):
            self.client = customClient
        }
        listenToUpdates()
    }

    deinit {
        tasks.forEach { $0.cancel() }
    }

    public func start() {
        Task {
            do {
                try await client.initialize()
                let folders = try await client.getChatFolders()
                await MainActor.run {
                    self.chatFolders = folders
                }
            } catch {
                await MainActor.run {
                    let errorDesc = error.localizedDescription
                    self.lastError = errorDesc
                    // Visible error state on critical path
                    self.authState = .error(errorDesc)
                }
            }
        }
    }

    private func listenToUpdates() {
        // Auth State listening
        let authTask = Task { [weak self] in
            guard let self = self else { return }
            for await state in self.client.authStateStream {
                await MainActor.run {
                    self.authState = state
                    if case .ready(let user) = state {
                        self.currentUser = user
                        self.isConnected = true
                    } else {
                        self.isConnected = false
                    }
                }
            }
        }
        tasks.append(authTask)

        // Chats listening
        let chatsTask = Task { [weak self] in
            guard let self = self else { return }
            for await newChats in self.client.chatsStream {
                await MainActor.run {
                    self.chats = newChats
                }
            }
        }
        tasks.append(chatsTask)
    }

    // MARK: - High-Level Actions With Strict Error Propagation

    public func sendPhoneNumber(_ number: String) async throws {
        lastError = nil
        do {
            try await client.setPhoneNumber(number)
        } catch {
            await MainActor.run { self.lastError = error.localizedDescription }
            throw error
        }
    }

    public func sendAuthCode(_ code: String) async throws {
        lastError = nil
        do {
            try await client.checkAuthenticationCode(code)
        } catch {
            await MainActor.run { self.lastError = error.localizedDescription }
            throw error
        }
    }

    public func sendPassword(_ password: String) async throws {
        lastError = nil
        do {
            try await client.checkAuthenticationPassword(password)
        } catch {
            await MainActor.run { self.lastError = error.localizedDescription }
            throw error
        }
    }

    public func logOut() async throws {
        do {
            try await client.logOut()
        } catch {
            await MainActor.run { self.lastError = error.localizedDescription }
            throw error
        }
    }

    public func sendTextMessage(chatId: Int64, text: String, replyToId: Int64? = nil) async throws -> TelegramMessage {
        do {
            return try await client.sendTextMessage(chatId: chatId, text: text, replyToMessageId: replyToId)
        } catch {
            await MainActor.run { self.lastError = error.localizedDescription }
            throw error
        }
    }

    public func loadMessages(chatId: Int64) async throws -> [TelegramMessage] {
        do {
            return try await client.getMessages(chatId: chatId, fromMessageId: 0, limit: 50)
        } catch {
            await MainActor.run { self.lastError = error.localizedDescription }
            throw error
        }
    }

    public func addReaction(chatId: Int64, messageId: Int64, emoji: String) async throws {
        do {
            try await client.addReaction(chatId: chatId, messageId: messageId, reaction: emoji)
        } catch {
            await MainActor.run { self.lastError = error.localizedDescription }
            throw error
        }
    }
}
