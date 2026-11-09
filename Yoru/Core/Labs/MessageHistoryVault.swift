import Foundation

public struct MessageHistoryKey: Hashable, Codable {
    public let chatId: Int64
    public let messageId: Int64

    public init(chatId: Int64, messageId: Int64) {
        self.chatId = chatId
        self.messageId = messageId
    }
}

public struct StoredMessageRecord: Identifiable, Codable, Equatable {
    public let id: Int64
    public let accountId: Int64
    public let chatId: Int64
    public let senderId: Int64
    public let senderName: String
    public let text: String
    public let timestamp: Date
    public var isDeletedLocally: Bool
    public var deletedAt: Date?
    public var editRevisions: [String]

    public var key: MessageHistoryKey {
        MessageHistoryKey(chatId: chatId, messageId: id)
    }

    public init(
        id: Int64,
        accountId: Int64 = 0,
        chatId: Int64,
        senderId: Int64,
        senderName: String,
        text: String,
        timestamp: Date,
        isDeletedLocally: Bool = false,
        deletedAt: Date? = nil,
        editRevisions: [String] = []
    ) {
        self.id = id
        self.accountId = accountId
        self.chatId = chatId
        self.senderId = senderId
        self.senderName = senderName
        self.text = text
        self.timestamp = timestamp
        self.isDeletedLocally = isDeletedLocally
        self.deletedAt = deletedAt
        self.editRevisions = editRevisions
    }
}

/// Actor managing message history and anti-recall retention.
///
/// STORAGE SPECIFICATION:
/// 1. Volatile In-Memory Storage: Composite-keyed by `[AccountId: [MessageHistoryKey: StoredMessageRecord]]`.
///    Ensures messages with identical IDs in different chats do NOT collide.
/// 2. Persistent On-Disk Storage: Serialized JSON records written with Apple iOS Data Protection
///    (`Data.WritingOptions.completeFileProtection`). This relies strictly on iOS hardware-backed
///    Secure Enclave key derivation when the physical device is locked, NOT application-level software AES.
public actor MessageHistoryVault {
    public static let shared = MessageHistoryVault()

    // MARK: - Volatile In-Memory Storage: [AccountId: [MessageHistoryKey: StoredMessageRecord]]
    private var volatileCache: [Int64: [MessageHistoryKey: StoredMessageRecord]] = [:]

    // Directory for persistent storage
    private let vaultDirectoryURL: URL?

    public init(customBaseURL: URL? = nil) {
        if let customBaseURL = customBaseURL {
            self.vaultDirectoryURL = customBaseURL
        } else {
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            let dir = appSupport?.appendingPathComponent("Yoru/Vaults", isDirectory: true)
            if let dir = dir {
                try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            }
            self.vaultDirectoryURL = dir
        }
    }

    // MARK: - In-Memory Volatile Cache Operations (Composite ChatId + MessageId Keyed)

    public func recordIncomingMessage(
        accountId: Int64 = 0,
        id: Int64,
        chatId: Int64,
        senderId: Int64,
        senderName: String,
        text: String,
        date: Date
    ) {
        let key = MessageHistoryKey(chatId: chatId, messageId: id)
        var accountRecords = volatileCache[accountId] ?? [:]
        if accountRecords[key] == nil {
            accountRecords[key] = StoredMessageRecord(
                id: id,
                accountId: accountId,
                chatId: chatId,
                senderId: senderId,
                senderName: senderName,
                text: text,
                timestamp: date
            )
            volatileCache[accountId] = accountRecords
        }
    }

    public func recordEdit(accountId: Int64 = 0, chatId: Int64, messageId: Int64, newText: String) {
        let key = MessageHistoryKey(chatId: chatId, messageId: messageId)
        var accountRecords = volatileCache[accountId] ?? [:]
        if var record = accountRecords[key] {
            record.editRevisions.append(record.text)
            accountRecords[key] = StoredMessageRecord(
                id: record.id,
                accountId: record.accountId,
                chatId: record.chatId,
                senderId: record.senderId,
                senderName: record.senderName,
                text: newText,
                timestamp: record.timestamp,
                isDeletedLocally: record.isDeletedLocally,
                deletedAt: record.deletedAt,
                editRevisions: record.editRevisions
            )
            volatileCache[accountId] = accountRecords
        }
    }

    public func handleRemoteDeletion(accountId: Int64 = 0, chatId: Int64, messageId: Int64, antiRecallEnabled: Bool) -> StoredMessageRecord? {
        let key = MessageHistoryKey(chatId: chatId, messageId: messageId)
        var accountRecords = volatileCache[accountId] ?? [:]
        guard var record = accountRecords[key] else { return nil }

        if antiRecallEnabled {
            record.isDeletedLocally = true
            record.deletedAt = Date()
            accountRecords[key] = record
            volatileCache[accountId] = accountRecords
            return record
        } else {
            accountRecords.removeValue(forKey: key)
            volatileCache[accountId] = accountRecords
            return nil
        }
    }

    public func getRecord(accountId: Int64 = 0, chatId: Int64, messageId: Int64) -> StoredMessageRecord? {
        let key = MessageHistoryKey(chatId: chatId, messageId: messageId)
        return volatileCache[accountId]?[key]
    }

    public func getDeletedMessages(accountId: Int64 = 0, chatId: Int64) -> [StoredMessageRecord] {
        guard let accountRecords = volatileCache[accountId] else { return [] }
        return accountRecords.values.filter { $0.chatId == chatId && $0.isDeletedLocally }
    }

    public func purgeOldRecords(accountId: Int64 = 0, retentionDays: Int) {
        guard var accountRecords = volatileCache[accountId] else { return }
        let cutoff = Date().addingTimeInterval(-Double(retentionDays * 86400))
        accountRecords = accountRecords.filter { $0.value.timestamp >= cutoff }
        volatileCache[accountId] = accountRecords
    }

    // MARK: - Persistent Storage (iOS Hardware File Protection)

    private func vaultFileURL(for accountId: Int64) -> URL? {
        vaultDirectoryURL?.appendingPathComponent("vault_\(accountId).dat")
    }

    /// Persists volatile memory cache to disk file protected by iOS Secure Enclave File Protection
    public func persistToDisk(accountId: Int64) throws {
        guard let fileURL = vaultFileURL(for: accountId),
              let records = volatileCache[accountId] else { return }

        let recordList = Array(records.values)
        let data = try JSONEncoder().encode(recordList)
        // Store with Apple Complete File Protection (hardware-encrypted until device unlocked)
        try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
    }

    /// Loads records from persistent file into volatile memory cache
    public func loadFromDisk(accountId: Int64) throws {
        guard let fileURL = vaultFileURL(for: accountId),
              FileManager.default.fileExists(atPath: fileURL.path) else { return }

        let data = try Data(contentsOf: fileURL)
        let records = try JSONDecoder().decode([StoredMessageRecord].self, from: data)

        var map: [MessageHistoryKey: StoredMessageRecord] = [:]
        for r in records {
            map[r.key] = r
        }
        volatileCache[accountId] = map
    }

    /// Purges all volatile and on-disk records for a specific account (e.g., upon user logout)
    public func wipeAccountData(accountId: Int64) {
        volatileCache.removeValue(forKey: accountId)
        if let fileURL = vaultFileURL(for: accountId) {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }

    /// Clears only volatile memory cache (keeps persistent disk file intact)
    public func clearVolatileCache(accountId: Int64) {
        volatileCache.removeValue(forKey: accountId)
    }
}
