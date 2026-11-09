import SwiftUI

@main
struct YoruApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var themeManager = ThemeManager.shared
    @State private var telegramService = TelegramService.shared

    init() {
        // Start Telegram Service
        telegramService.start()
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
