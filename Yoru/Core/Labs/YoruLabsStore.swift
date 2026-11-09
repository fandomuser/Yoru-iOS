import Foundation

public final class YoruLabsStore {
    public static let shared = YoruLabsStore()
    private let userDefaults: UserDefaults
    private let globalKey = "yoru_labs_global_settings"
    private let accountKeyPrefix = "yoru_labs_account_"

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Global Settings
    public func loadGlobalSettings() -> YoruLabsSettings {
        guard let data = userDefaults.data(forKey: globalKey),
              let settings = try? JSONDecoder().decode(YoruLabsSettings.self, from: data) else {
            return YoruLabsSettings()
        }
        return settings
    }

    public func saveGlobalSettings(_ settings: YoruLabsSettings) {
        if let data = try? JSONEncoder().encode(settings) {
            userDefaults.set(data, forKey: globalKey)
        }
    }

    // MARK: - Per-Account Isolated Settings
    public func loadAccountSettings(accountId: Int64) -> YoruLabsSettings {
        let key = "\(accountKeyPrefix)\(accountId)"
        guard let data = userDefaults.data(forKey: key),
              let settings = try? JSONDecoder().decode(YoruLabsSettings.self, from: data) else {
            // Fallback to global defaults if no account-specific settings exist yet
            return loadGlobalSettings()
        }
        return settings
    }

    public func saveAccountSettings(_ settings: YoruLabsSettings, accountId: Int64) {
        let key = "\(accountKeyPrefix)\(accountId)"
        if let data = try? JSONEncoder().encode(settings) {
            userDefaults.set(data, forKey: key)
        }
    }

    public func clearAccountSettings(accountId: Int64) {
        let key = "\(accountKeyPrefix)\(accountId)"
        userDefaults.removeObject(forKey: key)
    }
}
