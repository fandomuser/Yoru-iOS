import Foundation

public enum MessageDeliveryState: Equatable {
    case sending
    case sent
    case read
    case error(String)
}

public enum MessageContent: Equatable {
    case text(String)
    case photo(url: String?, caption: String?, width: Int, height: Int)
    case video(url: String?, caption: String?, duration: Int)
    case voice(url: String?, duration: Int, waveform: [Float])
    case document(fileName: String, fileSize: Int64, mimeType: String)
    case sticker(emoji: String, url: String?, width: Int, height: Int)
    case unsupported(String)
}

public struct MessageReaction: Identifiable, Equatable, Hashable {
    public var id: String { emoji }
    public let emoji: String
    public let count: Int
    public let isChosen: Bool

    public init(emoji: String, count: Int, isChosen: Bool = false) {
        self.emoji = emoji
        self.count = count
        self.isChosen = isChosen
    }
}

public struct TelegramMessage: Identifiable, Equatable {
    public let id: Int64
    public let chatId: Int64
    public let senderId: Int64
    public let senderName: String
    public let isOutgoing: Bool
    public let date: Date
    public let editDate: Date?
    public let content: MessageContent
    public let replyToMessageId: Int64?
    public let replyToSnippet: String?
    public let forwardInfo: String?
    public let reactions: [MessageReaction]
    public let deliveryState: MessageDeliveryState
    public let isPinned: Bool
    public let isDeletedLocally: Bool

    public init(
        id: Int64,
        chatId: Int64,
        senderId: Int64,
        senderName: String,
        isOutgoing: Bool,
        date: Date,
        editDate: Date? = nil,
        content: MessageContent,
        replyToMessageId: Int64? = nil,
        replyToSnippet: String? = nil,
        forwardInfo: String? = nil,
        reactions: [MessageReaction] = [],
        deliveryState: MessageDeliveryState = .sent,
        isPinned: Bool = false,
        isDeletedLocally: Bool = false
    ) {
        self.id = id
        self.chatId = chatId
        self.senderId = senderId
        self.senderName = senderName
        self.isOutgoing = isOutgoing
        self.date = date
        self.editDate = editDate
        self.content = content
        self.replyToMessageId = replyToMessageId
        self.replyToSnippet = replyToSnippet
        self.forwardInfo = forwardInfo
        self.reactions = reactions
        self.deliveryState = deliveryState
        self.isPinned = isPinned
        self.isDeletedLocally = isDeletedLocally
    }

    public static func == (lhs: TelegramMessage, rhs: TelegramMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.deliveryState == rhs.deliveryState &&
        lhs.reactions == rhs.reactions
    }
}
