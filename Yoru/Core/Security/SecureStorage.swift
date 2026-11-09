import Foundation
import Security

public final class SecureStorage {
    public static let shared = SecureStorage()
    private let tdlibKeyName = "yoru.tdlib.database_encryption_key"

    private init() {}

    /// Retrieves or generates a 256-bit cryptographically secure database encryption key
    public func getOrCreateTDLibEncryptionKey() -> String {
        if let existingData = try? KeychainService.shared.load(key: tdlibKeyName),
           let keyString = String(data: existingData, encoding: .utf8),
           !keyString.isEmpty {
            return keyString
        }

        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        let newKey = bytes.map { String(format: "%02hhx", $0) }.joined()

        if let data = newKey.data(using: .utf8) {
            try? KeychainService.shared.save(key: tdlibKeyName, data: data)
        }

        return newKey
    }

    public func clearAllCredentials() {
        try? KeychainService.shared.delete(key: tdlibKeyName)
    }
}
