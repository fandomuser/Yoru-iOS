import Foundation

public enum ChatType: Equatable {
    case `private`(userId: Int64)
    case basicGroup(groupId: Int64)
    case supergroup(supergroupId: Int64, isChannel: Bool)
    case secret(secretChatId: Int32)
}

public struct ChatFolder: Identifiable, Equatable, Hashable {
    public let id: Int32
    public let title: String
    public let iconName: String
    public let isAll: Bool

    public init(id: Int32, title: String, iconName: String = "folder.fill", isAll: Bool = false) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.isAll = isAll
    }
}

public struct TelegramChat: Identifiable, Equatable {
    public let id: Int64
    public let title: String
    public let type: ChatType
    public let avatarUrl: String?
    public let lastMessage: TelegramMessage?
    public let unreadCount: Int32
    public let unreadMentionCount: Int32
    public let isPinned: Bool
    public let isMuted: Bool
    public let isArchived: Bool
    public let draftMessage: String?
    public let lastReadInboxMessageId: Int64
    public let lastReadOutboxMessageId: Int64

    public init(
        id: Int64,
        title: String,
        type: ChatType,
        avatarUrl: String? = nil,
        lastMessage: TelegramMessage? = nil,
        unreadCount: Int32 = 0,
        unreadMentionCount: Int32 = 0,
        isPinned: Bool = false,
        isMuted: Bool = false,
        isArchived: Bool = false,
        draftMessage: String? = nil,
        lastReadInboxMessageId: Int64 = 0,
        lastReadOutboxMessageId: Int64 = 0
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.avatarUrl = avatarUrl
        self.lastMessage = lastMessage
        self.unreadCount = unreadCount
        self.unreadMentionCount = unreadMentionCount
        self.isPinned = isPinned
        self.isMuted = isMuted
        self.isArchived = isArchived
        self.draftMessage = draftMessage
        self.lastReadInboxMessageId = lastReadInboxMessageId
        self.lastReadOutboxMessageId = lastReadOutboxMessageId
    }

    public static func == (lhs: TelegramChat, rhs: TelegramChat) -> Bool {
        lhs.id == rhs.id &&
        lhs.unreadCount == rhs.unreadCount &&
        lhs.isPinned == rhs.isPinned &&
        lhs.lastMessage?.id == rhs.lastMessage?.id
    }
}
