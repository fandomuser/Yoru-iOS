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
}
