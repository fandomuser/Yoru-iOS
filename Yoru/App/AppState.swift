import SwiftUI
import Observation

public enum AppNavigationDestination: Hashable {
    case conversation(chatId: Int64)
    case themeStudio
    case securitySettings
    case userProfile(userId: Int64)
    case yoruLabs
    case labsPrivacy
    case labsHistory
    case labsFilters
    case labsAppearance
    case labsChat
    case labsTranslation
    case labsAI
    case labsAdvanced
}

@Observable
public final class AppState {
    public static let shared = AppState()

    public var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "yoru_onboarding_completed")
        }
    }

    public var selectedTab: YoruTab = .chats
    public var navigationPath = NavigationPath()
    public var activeChat: TelegramChat?
    public var selectedUserForProfile: TelegramUser?
    public var isShowingProfileModal: Bool = false

    public init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "yoru_onboarding_completed")
    }

    public func navigateToChat(_ chat: TelegramChat) {
        self.activeChat = chat
        navigationPath.append(AppNavigationDestination.conversation(chatId: chat.id))
    }

    public func openProfile(user: TelegramUser) {
        self.selectedUserForProfile = user
        self.isShowingProfileModal = true
    }
}
