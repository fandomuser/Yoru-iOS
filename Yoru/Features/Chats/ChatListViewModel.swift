import SwiftUI

@Observable
public final class ChatListViewModel {
    public var selectedFolderId: Int32 = 0
    public var searchText: String = ""
    public var isRefreshing: Bool = false

    private let telegramService: TelegramService

    public init(telegramService: TelegramService = .shared) {
        self.telegramService = telegramService
    }

    public var folders: [ChatFolder] {
        telegramService.chatFolders
    }

    public var chats: [TelegramChat] {
        let allChats = telegramService.chats
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return allChats
        } else {
            return allChats.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }

    public var totalUnreadCount: Int32 {
        telegramService.chats.reduce(0) { $0 + $1.unreadCount }
    }

    public func refresh() async {
        isRefreshing = true
        _ = try? await telegramService.client.loadChats(limit: 50)
        isRefreshing = false
    }
}
