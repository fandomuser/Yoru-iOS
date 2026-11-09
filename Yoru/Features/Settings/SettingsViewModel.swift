import SwiftUI

@Observable
public final class SettingsViewModel {
    public var enableNotifications: Bool = true
    public var enableSound: Bool = true
    public var saveIncomingPhotos: Bool = false
    public var cacheSize: String = "128 MB"
    public var isLoggingOut: Bool = false

    private let telegramService: TelegramService

    public init(telegramService: TelegramService = .shared) {
        self.telegramService = telegramService
    }

    public var currentUser: TelegramUser {
        telegramService.currentUser ?? MockDataGenerator.currentUser
    }

    public func clearCache() {
        cacheSize = "0 MB"
    }

    public func logOut() {
        isLoggingOut = true
        Task {
            try? await telegramService.logOut()
            await MainActor.run {
                self.isLoggingOut = false
            }
        }
    }
}
