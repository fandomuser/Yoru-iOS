import Foundation

public enum MockDataGenerator {
    public static let currentUser = TelegramUser(
        id: 777001,
        firstName: "Ren",
        lastName: "Amamiya",
        username: "joker_yoru",
        phoneNumber: "+81 90-1234-5678",
        avatarUrl: nil,
        bio: "Infiltrating cognitive palaces. Phantom Leader. Tokyo, JP 🌃",
        isVerified: true,
        isPremium: true,
        isBot: false,
        status: .online(expires: Date().addingTimeInterval(3600))
    )

    public static let sampleUsers: [TelegramUser] = [
        TelegramUser(
            id: 101,
            firstName: "Makoto",
            lastName: "Niijima",
            username: "queen_tactics",
            avatarUrl: nil,
            bio: "Student council president. Motorcycle & martial arts enthusiast.",
            isVerified: false,
            isPremium: true,
            status: .online(expires: Date().addingTimeInterval(1800))
        ),
        TelegramUser(
            id: 102,
            firstName: "Futaba",
            lastName: "Sakura",
            username: "navi_oracle",
            avatarUrl: nil,
            bio: "Hacking the Matrix. Do not disturb during raid nights.",
            isVerified: true,
            isPremium: false,
            status: .online(expires: Date().addingTimeInterval(7200))
        ),
        TelegramUser(
            id: 103,
            firstName: "Ryuji",
            lastName: "Sakamoto",
            username: "skull_runner",
            avatarUrl: nil,
            bio: "For real?! Track and field forever.",
            status: .offline(wasOnline: Date().addingTimeInterval(-1200))
        ),
        TelegramUser(
            id: 104,
            firstName: "Kasumi",
            lastName: "Yoshizawa",
            username: "violet_gymnast",
            avatarUrl: nil,
            bio: "Aiming for nationals! Ribbon gymnastics.",
            status: .recently
        )
    ]

    public static let sampleFolders: [ChatFolder] = [
        ChatFolder(id: 0, title: "All Chats", iconName: "tray.full.fill", isAll: true),
        ChatFolder(id: 1, title: "Personal", iconName: "person.fill"),
        ChatFolder(id: 2, title: "Cyber Syndicate", iconName: "bolt.shield.fill"),
        ChatFolder(id: 3, title: "Channels", iconName: "antenna.radiowaves.left.and.right")
    ]

    public static func sampleChats() -> [TelegramChat] {
        let now = Date()

        let chat1Msg = TelegramMessage(
            id: 1001,
            chatId: 201,
            senderId: 102,
            senderName: "Futaba Sakura",
            isOutgoing: false,
            date: now.addingTimeInterval(-180),
            content: .text("I cracked the mainframe cipher! Sending coordinates to your terminal now."),
            reactions: [MessageReaction(emoji: "⚡", count: 3, isChosen: true), MessageReaction(emoji: "🔥", count: 2)],
            deliveryState: .read
        )

        let chat2Msg = TelegramMessage(
            id: 1002,
            chatId: 202,
            senderId: 101,
            senderName: "Makoto Niijima",
            isOutgoing: false,
            date: now.addingTimeInterval(-1200),
            content: .text("Meeting at Shibuya Underground station at 22:00. Don't be late, Joker."),
            deliveryState: .read
        )

        let chat3Msg = TelegramMessage(
            id: 1003,
            chatId: 203,
            senderId: 777001,
            senderName: "Ren Amamiya",
            isOutgoing: true,
            date: now.addingTimeInterval(-4800),
            content: .text("Understood. Smoke canisters and grappling hooks prepped."),
            deliveryState: .read
        )

        let chat4Msg = TelegramMessage(
            id: 1004,
            chatId: 204,
            senderId: 501,
            senderName: "Neo Tokyo Dispatch",
            isOutgoing: false,
            date: now.addingTimeInterval(-10800),
            content: .text("BREAKING: Unidentified electromagnetic anomaly detected across Akihabara Sector 4."),
            deliveryState: .read
        )

        return [
            TelegramChat(
                id: 201,
                title: "Futaba Sakura (Navi)",
                type: .private(userId: 102),
                avatarUrl: nil,
                lastMessage: chat1Msg,
                unreadCount: 2,
                isPinned: true
            ),
            TelegramChat(
                id: 202,
                title: "Makoto Niijima",
                type: .private(userId: 101),
                avatarUrl: nil,
                lastMessage: chat2Msg,
                unreadCount: 0,
                isPinned: true
            ),
            TelegramChat(
                id: 203,
                title: "Phantom Thieves Syndicate",
                type: .supergroup(supergroupId: 888, isChannel: false),
                avatarUrl: nil,
                lastMessage: chat3Msg,
                unreadCount: 0,
                isPinned: false
            ),
            TelegramChat(
                id: 204,
                title: "Neo Tokyo Dispatch",
                type: .supergroup(supergroupId: 999, isChannel: true),
                avatarUrl: nil,
                lastMessage: chat4Msg,
                unreadCount: 14,
                isPinned: false
            )
        ]
    }

    public static func sampleMessages(for chatId: Int64) -> [TelegramMessage] {
        let now = Date()
        return [
            TelegramMessage(
                id: 901,
                chatId: chatId,
                senderId: 102,
                senderName: "Futaba Sakura",
                isOutgoing: false,
                date: now.addingTimeInterval(-3600),
                content: .text("Ren! Are you monitoring the encrypted subnet?"),
                deliveryState: .read
            ),
            TelegramMessage(
                id: 902,
                chatId: chatId,
                senderId: 777001,
                senderName: "Ren Amamiya",
                isOutgoing: true,
                date: now.addingTimeInterval(-3300),
                content: .text("Online now. Signal is clear. What did you find?"),
                deliveryState: .read
            ),
            TelegramMessage(
                id: 903,
                chatId: chatId,
                senderId: 102,
                senderName: "Futaba Sakura",
                isOutgoing: false,
                date: now.addingTimeInterval(-2400),
                content: .photo(url: nil, caption: "Spectrogram of the anomaly captured over Kanda.", width: 1200, height: 800),
                reactions: [MessageReaction(emoji: "✨", count: 4, isChosen: true)],
                deliveryState: .read
            ),
            TelegramMessage(
                id: 904,
                chatId: chatId,
                senderId: 102,
                senderName: "Futaba Sakura",
                isOutgoing: false,
                date: now.addingTimeInterval(-180),
                content: .text("I cracked the mainframe cipher! Sending coordinates to your terminal now."),
                reactions: [MessageReaction(emoji: "⚡", count: 3, isChosen: true), MessageReaction(emoji: "🔥", count: 2)],
                deliveryState: .read
            )
        ]
    }
}
