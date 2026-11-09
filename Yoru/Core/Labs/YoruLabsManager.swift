import Foundation
import Observation

public enum StreamerMaskType {
    case phoneNumber
    case username
    case chatTitle
}

@Observable
public final class YoruLabsManager {
    public static let shared = YoruLabsManager()

    public private(set) var currentSettings: YoruLabsSettings
    public private(set) var activeAccountId: Int64?
    private let store: YoruLabsStore

    public init(store: YoruLabsStore = .shared) {
        self.store = store
        self.currentSettings = store.loadGlobalSettings()
    }

    public func switchAccount(accountId: Int64?) {
        self.activeAccountId = accountId
        if let accountId = accountId {
            self.currentSettings = store.loadAccountSettings(accountId: accountId)
        } else {
            self.currentSettings = store.loadGlobalSettings()
        }
    }

    public func updateSettings(_ modifier: (inout YoruLabsSettings) -> Void) {
        modifier(&currentSettings)
        saveCurrentSettings()
    }

    private func saveCurrentSettings() {
        if let accountId = activeAccountId {
            store.saveAccountSettings(currentSettings, accountId: accountId)
        } else {
            store.saveGlobalSettings(currentSettings)
        }
    }

    // MARK: - Streamer Mode Masking
    public func maskIfStreamer(_ text: String, type: StreamerMaskType) -> String {
        guard currentSettings.advanced.streamerModeEnabled else {
            // Also honor individual hide flags
            switch type {
            case .phoneNumber:
                return currentSettings.appearance.hidePhoneNumber ? "+* *** ***-****" : text
            case .username:
                return currentSettings.appearance.hideUsernames ? "@anonymous" : text
            case .chatTitle:
                return text
            }
        }

        switch type {
        case .phoneNumber:
            return "+* *** ***-****"
        case .username:
            return "@hidden_user"
        case .chatTitle:
            if text.count > 2 {
                let first = text.prefix(1)
                return "\(first)*** (Encrypted Sector)"
            }
            return "***"
        }
    }

    // MARK: - Message Filter Evaluation
    public func filterMessageText(_ text: String) -> MessageFilterResult {
        return MessageFilterEngine.shared.evaluate(text: text, settings: currentSettings.filters)
    }
}
