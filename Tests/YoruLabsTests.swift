import XCTest
@testable import YoruCore

final class YoruLabsTests: XCTestCase {
    private var mockDefaults: UserDefaults!
    private var store: YoruLabsStore!

    override func setUp() {
        super.setUp()
        mockDefaults = UserDefaults(suiteName: "YoruLabsTest_\(UUID().uuidString)")
        store = YoruLabsStore(userDefaults: mockDefaults)
    }

    override func tearDown() {
        mockDefaults.removePersistentDomain(forName: mockDefaults.description)
        super.tearDown()
    }

    func testGlobalSettingsPersistence() {
        var settings = store.loadGlobalSettings()
        XCTAssertFalse(settings.advanced.streamerModeEnabled)

        settings.advanced.streamerModeEnabled = true
        settings.appearance.avatarShape = .cyberCut
        settings.appearance.bubbleCornerRadius = 24.0

        store.saveGlobalSettings(settings)

        let loaded = store.loadGlobalSettings()
        XCTAssertTrue(loaded.advanced.streamerModeEnabled)
        XCTAssertEqual(loaded.appearance.avatarShape, .cyberCut)
        XCTAssertEqual(loaded.appearance.bubbleCornerRadius, 24.0)
    }

    func testAccountSettingsIsolation() {
        let accountA: Int64 = 111001
        let accountB: Int64 = 222002

        // Account A configures anti-recall and stealth mode
        var settingsA = YoruLabsSettings()
        settingsA.privacy.stealthModeEnabled = true
        settingsA.history.antiRecallEnabled = true
        settingsA.appearance.avatarShape = .hexagon
        store.saveAccountSettings(settingsA, accountId: accountA)

        // Account B configures different settings
        var settingsB = YoruLabsSettings()
        settingsB.privacy.stealthModeEnabled = false
        settingsB.history.antiRecallEnabled = false
        settingsB.appearance.avatarShape = .circle
        store.saveAccountSettings(settingsB, accountId: accountB)

        // Assert isolation
        let loadedA = store.loadAccountSettings(accountId: accountA)
        let loadedB = store.loadAccountSettings(accountId: accountB)
        let global = store.loadGlobalSettings()

        XCTAssertTrue(loadedA.privacy.stealthModeEnabled)
        XCTAssertEqual(loadedA.appearance.avatarShape, .hexagon)

        XCTAssertFalse(loadedB.privacy.stealthModeEnabled)
        XCTAssertEqual(loadedB.appearance.avatarShape, .circle)

        // Global defaults should remain unaffected
        XCTAssertFalse(global.privacy.stealthModeEnabled)
    }

    func testKeywordMessageFiltering() {
        let engine = MessageFilterEngine.shared
        var filterSettings = MessageFilterSettings()
        filterSettings.filterEnabled = true
        filterSettings.blockedKeywords = ["free tokens", "airdrop claim"]
        filterSettings.action = .collapse

        // Clean message
        let cleanResult = engine.evaluate(text: "Hello Joker, meet at Shibuya station.", settings: filterSettings)
        XCTAssertEqual(cleanResult, .allowed)

        // Scam keyword message
        let scamResult = engine.evaluate(text: "Click here to get your free tokens now!", settings: filterSettings)
        if case .collapsed(let reason) = scamResult {
            XCTAssertTrue(reason.contains("free tokens"))
        } else {
            XCTFail("Expected collapsed filter result")
        }
    }

    func testRegexPatternMessageFiltering() {
        let engine = MessageFilterEngine.shared
        var filterSettings = MessageFilterSettings()
        filterSettings.filterEnabled = true
        filterSettings.regexPatterns = [#"(?i)\b(t\.me\/\+[a-zA-Z0-9_\-]+)\b"#]
        filterSettings.action = .blur

        let inviteMessage = "Join our secret channel here: https://t.me/+AbCdEfGhIjKlMn"
        let result = engine.evaluate(text: inviteMessage, settings: filterSettings)

        if case .blurred(let reason) = result {
            XCTAssertTrue(reason.contains("Matched Pattern Filter"))
        } else {
            XCTFail("Expected blurred result for invite link regex")
        }
    }

    func testStreamerModeMasking() {
        let manager = YoruLabsManager(store: store)

        // With streamer mode OFF
        let originalPhone = "+1 (555) 019-2831"
        let originalUser = "joker_phantom"
        XCTAssertEqual(manager.maskIfStreamer(originalPhone, type: .phoneNumber), originalPhone)
        XCTAssertEqual(manager.maskIfStreamer(originalUser, type: .username), originalUser)

        // With streamer mode ON
        manager.updateSettings { $0.advanced.streamerModeEnabled = true }
        XCTAssertEqual(manager.maskIfStreamer(originalPhone, type: .phoneNumber), "+* *** ***-****")
        XCTAssertEqual(manager.maskIfStreamer(originalUser, type: .username), "@hidden_user")
    }

    func testAntiRecallMessageVault() async {
        let vault = MessageHistoryVault.shared
        let msgId: Int64 = 888123
        let chatId: Int64 = 501

        await vault.recordIncomingMessage(
            id: msgId,
            chatId: chatId,
            senderId: 101,
            senderName: "Makoto Niijima",
            text: "Confidential Phantom Thieves tactical plan.",
            date: Date()
        )

        // When Anti-Recall is enabled, deletion flags it locally
        let retained = await vault.handleRemoteDeletion(chatId: chatId, messageId: msgId, antiRecallEnabled: true)
        XCTAssertNotNil(retained)
        XCTAssertTrue(retained!.isDeletedLocally)
        XCTAssertEqual(retained!.text, "Confidential Phantom Thieves tactical plan.")

        // When Anti-Recall is disabled, deletion purges record
        let msgId2: Int64 = 888124
        await vault.recordIncomingMessage(
            id: msgId2,
            chatId: chatId,
            senderId: 101,
            senderName: "Makoto Niijima",
            text: "Temporary message.",
            date: Date()
        )
        let deleted = await vault.handleRemoteDeletion(chatId: chatId, messageId: msgId2, antiRecallEnabled: false)
        XCTAssertNil(deleted)
        let record = await vault.getRecord(chatId: chatId, messageId: msgId2)
        XCTAssertNil(record)
    }

    func testVaultAccountScopingAndDiskPersistence() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("VaultTest_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let vault = MessageHistoryVault(customBaseURL: tempDir)
        let accountA: Int64 = 777001
        let accountB: Int64 = 888002

        // Record message in Account A
        await vault.recordIncomingMessage(
            accountId: accountA,
            id: 1001,
            chatId: 201,
            senderId: 102,
            senderName: "Futaba Sakura",
            text: "Account A Confidential Packet",
            date: Date()
        )

        // Record message in Account B
        await vault.recordIncomingMessage(
            accountId: accountB,
            id: 2002,
            chatId: 301,
            senderId: 101,
            senderName: "Makoto Niijima",
            text: "Account B Strategy",
            date: Date()
        )

        // Verify account isolation
        let recA = await vault.getRecord(accountId: accountA, chatId: 201, messageId: 1001)
        let recAInB = await vault.getRecord(accountId: accountB, chatId: 201, messageId: 1001)
        XCTAssertNotNil(recA)
        XCTAssertNil(recAInB, "Account B must not see Account A records")

        // Persist Account A to disk
        try await vault.persistToDisk(accountId: accountA)

        // Clear volatile memory cache for Account A
        await vault.clearVolatileCache(accountId: accountA)
        let recCleared = await vault.getRecord(accountId: accountA, chatId: 201, messageId: 1001)
        XCTAssertNil(recCleared, "Volatile cache must be empty after clearing")

        // Reload from disk
        try await vault.loadFromDisk(accountId: accountA)
        let recReloaded = await vault.getRecord(accountId: accountA, chatId: 201, messageId: 1001)
        XCTAssertNotNil(recReloaded, "Records must be restored from persistent store")
        XCTAssertEqual(recReloaded?.text, "Account A Confidential Packet")
    }

    func testVaultChatIdMessageIdCollisionResistance() async {
        let vault = MessageHistoryVault.shared
        let commonMessageId: Int64 = 99999
        let chat1: Int64 = 101
        let chat2: Int64 = 202

        // Record message with ID 99999 in Chat 101
        await vault.recordIncomingMessage(
            id: commonMessageId,
            chatId: chat1,
            senderId: 1,
            senderName: "Sender 1",
            text: "Message in Chat 101",
            date: Date()
        )

        // Record DIFFERENT message with SAME ID 99999 in Chat 202
        await vault.recordIncomingMessage(
            id: commonMessageId,
            chatId: chat2,
            senderId: 2,
            senderName: "Sender 2",
            text: "Message in Chat 202",
            date: Date()
        )

        // Verify NO collision occurs
        let rec1 = await vault.getRecord(chatId: chat1, messageId: commonMessageId)
        let rec2 = await vault.getRecord(chatId: chat2, messageId: commonMessageId)

        XCTAssertNotNil(rec1)
        XCTAssertNotNil(rec2)
        XCTAssertEqual(rec1?.text, "Message in Chat 101")
        XCTAssertEqual(rec2?.text, "Message in Chat 202")
    }
}
