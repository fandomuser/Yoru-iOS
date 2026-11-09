import XCTest
@testable import YoruCore
@testable import YoruTelegram

final class YoruTests: XCTestCase {
    func testThemeSwitching() {
        let manager = ThemeManager.shared
        manager.selectTheme(.crimsonMoon)
        XCTAssertEqual(manager.currentThemeID, .crimsonMoon)
        XCTAssertEqual(manager.currentTheme.name, "Crimson Moon")

        manager.selectTheme(.tokyoNight)
        XCTAssertEqual(manager.currentThemeID, .tokyoNight)
        XCTAssertEqual(manager.currentTheme.name, "Tokyo Night")
    }

    func testMockTelegramClientAuthLoop() async throws {
        let client = MockTelegramClient(initialState: .waitingForPhoneNumber)
        try await client.initialize()

        // Set phone number
        try await client.setPhoneNumber("+1234567890")

        // Check authentication code with non-2 suffix (instant ready)
        try await client.checkAuthenticationCode("54321")
        let user = try await client.getCurrentUser()
        XCTAssertEqual(user.id, 777001)
        XCTAssertEqual(user.username, "joker_yoru")
    }

    func testMockChatsAndMessaging() async throws {
        let client = MockTelegramClient()
        let chats = try await client.loadChats(limit: 10)
        XCTAssertFalse(chats.isEmpty)

        let firstChat = chats[0]
        let message = try await client.sendTextMessage(chatId: firstChat.id, text: "Testing transmission", replyToMessageId: nil)
        XCTAssertEqual(message.chatId, firstChat.id)
        if case .text(let txt) = message.content {
            XCTAssertEqual(txt, "Testing transmission")
        } else {
            XCTFail("Expected text content")
        }
    }

    /// Local unit test verifying error mapping, unlinked bridge fallback state, and Keychain encryption key formatting.
    /// NOTE: This is an offline local unit test. It does NOT perform live network authorization against Telegram Test DC.
    func testLocalTDLibErrorAndStorageConfiguration() async {
        // Validate that TDLibError maintains structured error codes and messages
        let error = TDLibError(code: 400, message: "PHONE_NUMBER_INVALID")
        XCTAssertEqual(error.code, 400)
        XCTAssertEqual(error.message, "PHONE_NUMBER_INVALID")
        XCTAssertTrue(error.errorDescription?.contains("400") == true)

        // Validate that TDLibBridge identifies unavailability gracefully when not linked
        let bridge = TDLibBridge()
        let initialized = await bridge.isInitialized
        XCTAssertFalse(initialized)

        // Validate that SecureStorage provides a valid, persistent TDLib database encryption key
        let key1 = SecureStorage.shared.getOrCreateTDLibEncryptionKey()
        let key2 = SecureStorage.shared.getOrCreateTDLibEncryptionKey()
        XCTAssertFalse(key1.isEmpty)
        XCTAssertEqual(key1, key2)
        XCTAssertEqual(key1.count, 64) // 32 bytes hex-encoded
    }
}
