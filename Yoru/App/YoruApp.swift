import SwiftUI

@main
struct YoruApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var themeManager = ThemeManager.shared
    @State private var telegramService: TelegramService

    init() {
        let args = CommandLine.arguments
        if let idx = args.firstIndex(of: "-screen"), idx + 1 < args.count {
            let screen = args[idx + 1].lowercased()
            if screen != "login" && screen != "onboarding" {
                TelegramService.shared = TelegramService(mode: .preview)
            }
        }
        _telegramService = State(initialValue: TelegramService.shared)
        applyPreviewLaunchArguments()
        // Start Telegram Service
        TelegramService.shared.start()
    }

    private func applyPreviewLaunchArguments() {
        let args = CommandLine.arguments
        guard let screenIdx = args.firstIndex(of: "-screen"), screenIdx + 1 < args.count else {
            return
        }
        let screen = args[screenIdx + 1].lowercased()
        switch screen {
        case "onboarding":
            AppState.shared.hasCompletedOnboarding = false

        case "login":
            AppState.shared.hasCompletedOnboarding = true

        case "chatlist":
            AppState.shared.hasCompletedOnboarding = true
            AppState.shared.selectedTab = .chats

        case "conversation":
            AppState.shared.hasCompletedOnboarding = true
            AppState.shared.selectedTab = .chats
            let sampleChat = MockDataGenerator.sampleChats()[0]
            AppState.shared.activeChat = sampleChat
            AppState.shared.navigationPath.append(AppNavigationDestination.conversation(chatId: sampleChat.id))

        case "settings":
            AppState.shared.hasCompletedOnboarding = true
            AppState.shared.selectedTab = .settings

        case "labs":
            AppState.shared.hasCompletedOnboarding = true
            AppState.shared.selectedTab = .settings
            AppState.shared.navigationPath.append(AppNavigationDestination.yoruLabs)

        case "themes":
            AppState.shared.hasCompletedOnboarding = true
            AppState.shared.selectedTab = .settings
            AppState.shared.navigationPath.append(AppNavigationDestination.themeStudio)

        default:
            break
        }
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .environment(\.yoruTheme, themeManager.currentTheme)
                .preferredColorScheme(.dark)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            guard let accountId = telegramService.currentUser?.id, accountId > 0 else {
                return
            }
            switch newPhase {
            case .background:
                // Persist message history vault before suspension
                Task {
                    do {
                        try await MessageHistoryVault.shared.persistToDisk(accountId: accountId)
                    } catch {
                        YoruLogger.shared.log(
                            "Failed to persist message history vault for account \(accountId): \(error.localizedDescription)",
                            level: .error
                        )
                    }
                }
            case .active:
                // Restore message history vault upon resuming
                Task {
                    do {
                        try await MessageHistoryVault.shared.loadFromDisk(accountId: accountId)
                    } catch {
                        YoruLogger.shared.log(
                            "Failed to load message history vault for account \(accountId): \(error.localizedDescription)",
                            level: .error
                        )
                    }
                }
            default:
                break
            }
        }
    }
}
