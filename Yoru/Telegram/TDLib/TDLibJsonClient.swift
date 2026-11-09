import Foundation
import Combine
import os
#if canImport(YoruCore)
import YoruCore
#endif

public struct TDLibError: LocalizedError, Equatable {
    public let code: Int
    public let message: String

    public init(code: Int, message: String) {
        self.code = code
        self.message = message
    }

    public var errorDescription: String? {
        "Telegram TDLib Error (\(code)): \(message)"
    }
}

private struct QueryState {
    var pending: [String: CheckedContinuation<[String: Any], Error>] = [:]
}

private struct CacheState {
    var chats: [Int64: TelegramChat] = [:]
    var users: [Int64: TelegramUser] = [:]
}

/// Production TDLib implementation conforming to TelegramClientProtocol.
/// Connects directly to TDLib C JSON API with thread-safe query routing,
/// cooperative cancellation, and full authorization/connection state handling.
public final class TDLibJsonClient: TelegramClientProtocol {
    private let bridge: TDLibBridge
    private var receiveTask: Task<Void, Never>?
    private let queryState = OSAllocatedUnfairLock(initialState: QueryState())

    // Continuations for reactive streams
    private var authContinuation: AsyncStream<TelegramAuthState>.Continuation?
    private var chatsContinuation: AsyncStream<[TelegramChat]>.Continuation?
    private var messageContinuation: AsyncStream<TelegramMessage>.Continuation?

    // Local caches updated via real TDLib event stream with thread-safe access
    private let cacheState = OSAllocatedUnfairLock(initialState: CacheState())
    private var currentMeUser: TelegramUser?

    // Stored initialization parameters for sequential TDLib state machine dispatch
    private var isParametersSent = false
    private var useTestDC: Bool = false
    private var configuredApiId: Int = 0
    private var configuredApiHash: String = ""
    private var configuredDbDir: String = ""
    private var configuredFilesDir: String = ""

    public lazy var authStateStream: AsyncStream<TelegramAuthState> = {
        AsyncStream { continuation in
            self.authContinuation = continuation
        }
    }()

    public lazy var chatsStream: AsyncStream<[TelegramChat]> = {
        AsyncStream { continuation in
            self.chatsContinuation = continuation
        }
    }()

    public lazy var messageUpdatesStream: AsyncStream<TelegramMessage> = {
        AsyncStream { continuation in
            self.messageContinuation = continuation
        }
    }()

    public init(bridge: TDLibBridge = TDLibBridge()) {
        self.bridge = bridge
    }

    deinit {
        receiveTask?.cancel()
    }

    public func initialize() async throws {
        try await initialize(useTestDC: false)
    }

    public func initialize(useTestDC: Bool) async throws {
        self.useTestDC = useTestDC
        self.isParametersSent = false

        // 1. Resolve and validate credentials
        let rawApiId = Bundle.main.object(forInfoDictionaryKey: "YORU_TELEGRAM_API_ID")
        let apiId: Int = {
            if let intVal = rawApiId as? Int { return intVal }
            if let strVal = rawApiId as? String, let intVal = Int(strVal.trimmingCharacters(in: .whitespacesAndNewlines)) { return intVal }
            return 0
        }()
        let rawApiHash = Bundle.main.object(forInfoDictionaryKey: "YORU_TELEGRAM_API_HASH") as? String ?? ""
        let apiHash = rawApiHash.trimmingCharacters(in: CharacterSet(charactersIn: "\" \t\n\r"))

        guard apiId > 0 && !apiHash.isEmpty else {
            throw TDLibError(
                code: 400,
                message: "Missing or invalid Telegram credentials (YORU_TELEGRAM_API_ID / YORU_TELEGRAM_API_HASH). Please configure Config.xcconfig."
            )
        }

        self.configuredApiId = apiId
        self.configuredApiHash = apiHash

        // 2. Resolve database and file storage paths
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let subfolder = useTestDC ? "tdlib_test" : "tdlib"
        let filesSubfolder = useTestDC ? "tdlib_files_test" : "tdlib_files"
        let tdlibDir = documentsDirectory.appendingPathComponent(subfolder, isDirectory: true)
        let tdlibFilesDir = documentsDirectory.appendingPathComponent(filesSubfolder, isDirectory: true)

        try FileManager.default.createDirectory(at: tdlibDir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: tdlibFilesDir, withIntermediateDirectories: true)

        self.configuredDbDir = tdlibDir.path
        self.configuredFilesDir = tdlibFilesDir.path

        // 3. Initialize native client instance and start background event loop
        try await bridge.createClient()
        startReceiveLoop()

        // Note: setTdlibParameters is dispatched exclusively in response to
        // authorizationStateWaitTdlibParameters event according to official TDLib state machine.
    }

    public func close() async {
        receiveTask?.cancel()
        receiveTask = nil

        // Cancel all pending queries safely under scoped lock
        let pendingToCancel = queryState.withLock { state -> [CheckedContinuation<[String: Any], Error>] in
            let list = Array(state.pending.values)
            state.pending.removeAll()
            return list
        }
        for continuation in pendingToCancel {
            continuation.resume(throwing: TDLibError(code: -1, message: "Client session closed"))
        }

        await bridge.destroy()
        authContinuation?.finish()
        chatsContinuation?.finish()
        messageContinuation?.finish()
    }

    private func startReceiveLoop() {
        guard receiveTask == nil else { return }

        receiveTask = Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            while !Task.isCancelled {
                if let jsonStr = await self.bridge.receive(timeout: 1.0) {
                    self.handleIncomingJson(jsonStr)
                }
            }
        }
    }

    private func handleIncomingJson(_ jsonString: String) {
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["@type"] as? String else {
            return
        }

        // 1. Route @extra query responses
        if let extra = json["@extra"] as? String {
            let continuation = queryState.withLock { state in
                state.pending.removeValue(forKey: extra)
            }

            if let continuation = continuation {
                if type == "error" {
                    let code = json["code"] as? Int ?? -1
                    let msg = json["message"] as? String ?? "Unknown TDLib error"
                    continuation.resume(throwing: TDLibError(code: code, message: msg))
                } else {
                    continuation.resume(returning: json)
                }
            }
            return
        }

        // 2. Process asynchronous TDLib updates
        switch type {
        case "updateAuthorizationState":
            if let authObj = json["authorization_state"] as? [String: Any],
               let authType = authObj["@type"] as? String {
                mapAuthState(authType, payload: authObj)
            }

        case "updateNewChat":
            if let chatObj = json["chat"] as? [String: Any],
               let chat = parseChat(chatObj) {
                let sortedChats = cacheState.withLock { state -> [TelegramChat] in
                    state.chats[chat.id] = chat
                    return Array(state.chats.values).sorted(by: { $0.isPinned && !$1.isPinned })
                }
                chatsContinuation?.yield(sortedChats)
            }

        case "updateChatLastMessage":
            if let chatId = json["chat_id"] as? Int64,
               let lastMsgObj = json["last_message"] as? [String: Any],
               let lastMsg = parseMessage(lastMsgObj) {
                let sortedChats: [TelegramChat]? = cacheState.withLock { state in
                    guard var chat = state.chats[chatId] else { return nil }
                    chat = TelegramChat(
                        id: chat.id,
                        title: chat.title,
                        type: chat.type,
                        avatarUrl: chat.avatarUrl,
                        lastMessage: lastMsg,
                        unreadCount: chat.unreadCount,
                        unreadMentionCount: chat.unreadMentionCount,
                        isPinned: chat.isPinned,
                        isMuted: chat.isMuted,
                        isArchived: chat.isArchived,
                        draftMessage: chat.draftMessage,
                        lastReadInboxMessageId: chat.lastReadInboxMessageId,
                        lastReadOutboxMessageId: chat.lastReadOutboxMessageId
                    )
                    state.chats[chatId] = chat
                    return Array(state.chats.values).sorted(by: { $0.isPinned && !$1.isPinned })
                }
                if let sorted = sortedChats {
                    chatsContinuation?.yield(sorted)
                }
            }

        case "updateNewMessage":
            if let msgObj = json["message"] as? [String: Any],
               let message = parseMessage(msgObj) {
                messageContinuation?.yield(message)
            }

        case "updateUser":
            if let userObj = json["user"] as? [String: Any],
               let user = parseUser(userObj) {
                cacheState.withLock { state in
                    state.users[user.id] = user
                }
            }

        case "updateUserStatus":
            if let userId = json["user_id"] as? Int64,
               let statusObj = json["status"] as? [String: Any] {
                cacheState.withLock { state in
                    if let user = state.users[userId] {
                        let updatedUser = TelegramUser(
                            id: user.id,
                            firstName: user.firstName,
                            lastName: user.lastName,
                            username: user.username,
                            phoneNumber: user.phoneNumber,
                            avatarUrl: user.avatarUrl,
                            bio: user.bio,
                            isVerified: user.isVerified,
                            isPremium: user.isPremium,
                            isBot: user.isBot,
                            status: parseUserStatus(statusObj)
                        )
                        state.users[userId] = updatedUser
                    }
                }
            }

        default:
            break
        }
    }

    private func sendTdlibParameters() async {
        guard !isParametersSent else { return }
        isParametersSent = true

        let setParams: [String: Any] = [
            "@type": "setTdlibParameters",
            "use_test_dc": useTestDC,
            "database_directory": configuredDbDir,
            "files_directory": configuredFilesDir,
            "use_file_database": true,
            "use_chat_info_database": true,
            "use_message_database": true,
            "use_secret_chats": false,
            "api_id": configuredApiId,
            "api_hash": configuredApiHash,
            "system_language_code": Locale.current.language.languageCode?.identifier ?? "en",
            "device_model": "iPhone 17 Pro Max",
            "system_version": "iOS 17.0",
            "application_version": "0.1.0",
            "enable_storage_optimizer": true
        ]

        do {
            _ = try await executeQuery(setParams)
        } catch {
            authContinuation?.yield(.error("setTdlibParameters rejected by TDLib: \(error.localizedDescription)"))
        }
    }

    private func mapAuthState(_ type: String, payload: [String: Any]) {
        switch type {
        case "authorizationStateWaitTdlibParameters":
            authContinuation?.yield(.waitingForParameters)
            Task { [weak self] in
                await self?.sendTdlibParameters()
            }
        case "authorizationStateWaitEncryptionKey":
            Task { [weak self] in
                let dbKey = SecureStorage.shared.getOrCreateTDLibEncryptionKey()
                do {
                    _ = try await self?.executeQuery([
                        "@type": "checkDatabaseEncryptionKey",
                        "encryption_key": dbKey
                    ])
                } catch {
                    self?.authContinuation?.yield(.error("checkDatabaseEncryptionKey rejected: \(error.localizedDescription)"))
                }
            }
        case "authorizationStateWaitPhoneNumber":
            authContinuation?.yield(.waitingForPhoneNumber)
        case "authorizationStateWaitCode":
            let codeInfo = payload["code_info"] as? [String: Any]
            let timeout = codeInfo?["timeout"] as? Int ?? 60
            authContinuation?.yield(.waitingForCode(type: .telegramApp, nextCodeType: .sms, timeout: timeout))
        case "authorizationStateWaitPassword":
            let hint = payload["password_hint"] as? String
            authContinuation?.yield(.waitingForPassword(hint: hint, hasRecovery: true))
        case "authorizationStateWaitRegistration":
            authContinuation?.yield(.waitingForRegistration)
        case "authorizationStateReady":
            Task {
                if let me = try? await self.getCurrentUser() {
                    self.currentMeUser = me
                    self.authContinuation?.yield(.ready(user: me))
                } else {
                    let fallbackUser = TelegramUser(id: 0, firstName: "Telegram User")
                    self.authContinuation?.yield(.ready(user: fallbackUser))
                }
            }
        case "authorizationStateLoggingOut":
            authContinuation?.yield(.loggingOut)
        case "authorizationStateClosing":
            // Session closing down
            break
        case "authorizationStateClosed":
            authContinuation?.yield(.closed)
        default:
            break
        }
    }

    private func executeQuery(_ dict: [String: Any], timeoutSeconds: Double = 30.0) async throws -> [String: Any] {
        try Task.checkCancellation()

        var query = dict
        let extraId = UUID().uuidString
        query["@extra"] = extraId

        guard let data = try? JSONSerialization.data(withJSONObject: query),
              let jsonString = String(data: data, encoding: .utf8) else {
            throw TDLibError(code: -1, message: "JSON serialization failed for TDLib query")
        }

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                queryState.withLock { state in
                    state.pending[extraId] = continuation
                }

                Task {
                    do {
                        try await bridge.send(request: jsonString)
                    } catch {
                        let pending = queryState.withLock { state in
                            state.pending.removeValue(forKey: extraId)
                        }
                        pending?.resume(throwing: error)
                    }
                }

                if timeoutSeconds > 0 {
                    Task {
                        try? await Task.sleep(nanoseconds: UInt64(timeoutSeconds * 1_000_000_000))
                        let pending = queryState.withLock { state in
                            state.pending.removeValue(forKey: extraId)
                        }
                        let queryType = dict["@type"] as? String ?? "unknown"
                        pending?.resume(throwing: TDLibError(code: 408, message: "TDLib query '\(queryType)' timed out after \(timeoutSeconds)s"))
                    }
                }
            }
        } onCancel: {
            let pending = queryState.withLock { state in
                state.pending.removeValue(forKey: extraId)
            }
            pending?.resume(throwing: CancellationError())
        }
    }

    // MARK: - Protocol Implementation

    public func setPhoneNumber(_ phoneNumber: String) async throws {
        _ = try await executeQuery([
            "@type": "setAuthenticationPhoneNumber",
            "phone_number": phoneNumber
        ])
    }

    public func checkAuthenticationCode(_ code: String) async throws {
        _ = try await executeQuery([
            "@type": "checkAuthenticationCode",
            "code": code
        ])
    }

    public func checkAuthenticationPassword(_ password: String) async throws {
        _ = try await executeQuery([
            "@type": "checkAuthenticationPassword",
            "password": password
        ])
    }

    public func logOut() async throws {
        _ = try await executeQuery(["@type": "logOut"])
    }

    public func loadChats(limit: Int) async throws -> [TelegramChat] {
        let response = try await executeQuery([
            "@type": "getChats",
            "chat_list": ["@type": "chatListMain"],
            "limit": limit
        ])

        guard let chatIds = response["chat_ids"] as? [Int64] else {
            return []
        }

        var loadedChats: [TelegramChat] = []
        for chatId in chatIds {
            let chatResponse = try await executeQuery([
                "@type": "getChat",
                "chat_id": chatId
            ])
            if let chat = parseChat(chatResponse) {
                loadedChats.append(chat)
                cacheState.withLock { state in
                    state.chats[chat.id] = chat
                }
            }
        }

        chatsContinuation?.yield(loadedChats)
        return loadedChats
    }

    public func getChatFolders() async throws -> [ChatFolder] {
        var folders = [
            ChatFolder(id: 0, title: "All Chats", iconName: "tray.full.fill", isAll: true)
        ]

        if let response = try? await executeQuery(["@type": "getChatFilters"]),
           let chatFilters = response["chat_filters"] as? [[String: Any]] {
            for filter in chatFilters {
                if let id = filter["id"] as? Int32,
                   let title = filter["title"] as? String {
                    let icon = filter["icon_name"] as? String ?? "folder.fill"
                    folders.append(ChatFolder(id: id, title: title, iconName: icon))
                }
            }
        }
        return folders
    }

    public func openChat(chatId: Int64) async throws {
        _ = try await executeQuery(["@type": "openChat", "chat_id": chatId])
    }

    public func closeChat(chatId: Int64) async throws {
        _ = try await executeQuery(["@type": "closeChat", "chat_id": chatId])
    }

    public func getMessages(chatId: Int64, fromMessageId: Int64, limit: Int) async throws -> [TelegramMessage] {
        let response = try await executeQuery([
            "@type": "getChatHistory",
            "chat_id": chatId,
            "from_message_id": fromMessageId,
            "offset": 0,
            "limit": limit,
            "only_local": false
        ])

        guard let messagesArray = response["messages"] as? [[String: Any]] else {
            return []
        }

        var results: [TelegramMessage] = []
        for msgObj in messagesArray {
            if let msg = parseMessage(msgObj) {
                results.append(msg)
            }
        }
        return results.reversed()
    }

    public func sendTextMessage(chatId: Int64, text: String, replyToMessageId: Int64?) async throws -> TelegramMessage {
        var query: [String: Any] = [
            "@type": "sendMessage",
            "chat_id": chatId,
            "input_message_content": [
                "@type": "inputMessageText",
                "text": ["@type": "formattedText", "text": text]
            ]
        ]

        if let replyId = replyToMessageId {
            query["reply_to"] = [
                "@type": "inputMessageReplyToMessage",
                "message_id": replyId
            ]
        }

        let response = try await executeQuery(query)
        if let createdMessage = parseMessage(response) {
            return createdMessage
        }

        throw TDLibError(code: -1, message: "Failed to parse TDLib message response")
    }

    public func deleteMessages(chatId: Int64, messageIds: [Int64], revoke: Bool) async throws {
        _ = try await executeQuery([
            "@type": "deleteMessages",
            "chat_id": chatId,
            "message_ids": messageIds,
            "revoke": revoke
        ])
    }

    public func addReaction(chatId: Int64, messageId: Int64, reaction: String) async throws {
        _ = try await executeQuery([
            "@type": "addMessageReaction",
            "chat_id": chatId,
            "message_id": messageId,
            "reaction_type": ["@type": "reactionTypeEmoji", "emoji": reaction],
            "is_big": false,
            "update_recent_reactions": true
        ])
    }

    public func getCurrentUser() async throws -> TelegramUser {
        let response = try await executeQuery(["@type": "getMe"])
        if let user = parseUser(response) {
            self.currentMeUser = user
            return user
        }
        throw TDLibError(code: -1, message: "Failed to parse TDLib getMe response")
    }

    public func getUser(userId: Int64) async throws -> TelegramUser {
        if let cached = cacheState.withLock({ $0.users[userId] }) {
            return cached
        }

        let response = try await executeQuery(["@type": "getUser", "user_id": userId])
        if let user = parseUser(response) {
            cacheState.withLock { state in
                state.users[userId] = user
            }
            return user
        }
        throw TDLibError(code: -1, message: "Failed to parse TDLib getUser response")
    }

    public func searchGlobal(query: String) async throws -> [TelegramChat] {
        let response = try await executeQuery([
            "@type": "searchPublicChats",
            "query": query
        ])

        guard let chatIds = response["chat_ids"] as? [Int64] else {
            return []
        }

        var results: [TelegramChat] = []
        for chatId in chatIds {
            if let chatResp = try? await executeQuery(["@type": "getChat", "chat_id": chatId]),
               let chat = parseChat(chatResp) {
                results.append(chat)
            }
        }
        return results
    }

    // MARK: - JSON Parsing Helpers

    private func parseUser(_ dict: [String: Any]) -> TelegramUser? {
        guard let id = dict["id"] as? Int64 else { return nil }
        let firstName = dict["first_name"] as? String ?? ""
        let lastName = dict["last_name"] as? String ?? ""
        let usernames = dict["usernames"] as? [String: Any]
        let activeUsernames = usernames?["active_usernames"] as? [String]
        let username = activeUsernames?.first ?? dict["username"] as? String
        let phoneNumber = dict["phone_number"] as? String ?? ""
        let isVerified = dict["is_verified"] as? Bool ?? false
        let isPremium = dict["is_premium"] as? Bool ?? false
        let isBot = (dict["type"] as? [String: Any])?["@type"] as? String == "userTypeBot"

        let statusDict = dict["status"] as? [String: Any] ?? [:]
        let status = parseUserStatus(statusDict)

        return TelegramUser(
            id: id,
            firstName: firstName,
            lastName: lastName,
            username: username,
            phoneNumber: phoneNumber,
            avatarUrl: nil,
            bio: nil,
            isVerified: isVerified,
            isPremium: isPremium,
            isBot: isBot,
            status: status
        )
    }

    private func parseUserStatus(_ dict: [String: Any]) -> UserStatus {
        guard let type = dict["@type"] as? String else { return .recently }
        switch type {
        case "userStatusOnline":
            let expires = dict["expires"] as? Int ?? 0
            return .online(expires: Date(timeIntervalSince1970: TimeInterval(expires)))
        case "userStatusOffline":
            let wasOnline = dict["was_online"] as? Int ?? 0
            return .offline(wasOnline: wasOnline > 0 ? Date(timeIntervalSince1970: TimeInterval(wasOnline)) : nil)
        case "userStatusRecently":
            return .recently
        case "userStatusLastWeek":
            return .lastWeek
        case "userStatusLastMonth":
            return .lastMonth
        default:
            return .empty
        }
    }

    private func parseChat(_ dict: [String: Any]) -> TelegramChat? {
        guard let id = dict["id"] as? Int64,
              let title = dict["title"] as? String else { return nil }

        let unreadCount = dict["unread_count"] as? Int32 ?? 0
        let unreadMentionCount = dict["unread_mention_count"] as? Int32 ?? 0
        let isPinned = dict["is_pinned"] as? Bool ?? false
        let lastReadInbox = dict["last_read_inbox_message_id"] as? Int64 ?? 0
        let lastReadOutbox = dict["last_read_outbox_message_id"] as? Int64 ?? 0

        var lastMessage: TelegramMessage? = nil
        if let lastMsgObj = dict["last_message"] as? [String: Any] {
            lastMessage = parseMessage(lastMsgObj)
        }

        let typeObj = dict["type"] as? [String: Any]
        let typeStr = typeObj?["@type"] as? String ?? ""
        let chatType: ChatType
        switch typeStr {
        case "chatTypePrivate":
            let userId = typeObj?["user_id"] as? Int64 ?? 0
            chatType = .private(userId: userId)
        case "chatTypeBasicGroup":
            let groupId = typeObj?["basic_group_id"] as? Int64 ?? 0
            chatType = .basicGroup(groupId: groupId)
        case "chatTypeSupergroup":
            let sgId = typeObj?["supergroup_id"] as? Int64 ?? 0
            let isChannel = typeObj?["is_channel"] as? Bool ?? false
            chatType = .supergroup(supergroupId: sgId, isChannel: isChannel)
        default:
            chatType = .private(userId: 0)
        }

        return TelegramChat(
            id: id,
            title: title,
            type: chatType,
            avatarUrl: nil,
            lastMessage: lastMessage,
            unreadCount: unreadCount,
            unreadMentionCount: unreadMentionCount,
            isPinned: isPinned,
            lastReadInboxMessageId: lastReadInbox,
            lastReadOutboxMessageId: lastReadOutbox
        )
    }

    private func parseMessage(_ dict: [String: Any]) -> TelegramMessage? {
        guard let id = dict["id"] as? Int64,
              let chatId = dict["chat_id"] as? Int64 else { return nil }

        let isOutgoing = dict["is_outgoing"] as? Bool ?? false
        let dateInt = dict["date"] as? Int ?? 0
        let date = Date(timeIntervalSince1970: TimeInterval(dateInt))

        var senderId: Int64 = 0
        if let senderObj = dict["sender_id"] as? [String: Any] {
            senderId = senderObj["user_id"] as? Int64 ?? (senderObj["chat_id"] as? Int64 ?? 0)
        }

        let content = parseContent(dict["content"] as? [String: Any] ?? [:])

        return TelegramMessage(
            id: id,
            chatId: chatId,
            senderId: senderId,
            senderName: isOutgoing ? "Me" : "Transmission",
            isOutgoing: isOutgoing,
            date: date,
            content: content,
            deliveryState: isOutgoing ? .sent : .read
        )
    }

    private func parseContent(_ dict: [String: Any]) -> MessageContent {
        guard let type = dict["@type"] as? String else { return .unsupported("unknown") }
        switch type {
        case "messageText":
            let textObj = dict["text"] as? [String: Any]
            let text = textObj?["text"] as? String ?? ""
            return .text(text)
        case "messagePhoto":
            let captionObj = dict["caption"] as? [String: Any]
            let caption = captionObj?["text"] as? String
            return .photo(url: nil, caption: caption, width: 800, height: 600)
        case "messageVoiceNote":
            let voiceObj = dict["voice_note"] as? [String: Any]
            let duration = voiceObj?["duration"] as? Int ?? 0
            return .voice(url: nil, duration: duration, waveform: [])
        default:
            return .unsupported(type)
        }
    }
}
