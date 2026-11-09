import SwiftUI

@Observable
public final class ProfileViewModel {
    public var user: TelegramUser
    public var isMuted: Bool = false
    public var isNotificationsEnabled: Bool = true

    private let telegramService: TelegramService

    public init(user: TelegramUser = MockDataGenerator.currentUser, telegramService: TelegramService = .shared) {
        self.user = user
        self.telegramService = telegramService
    }
}
