# YORU (夜) — AyuGram-Inspired Features: Technical Research & Feasibility Study

**Topic:** Ghost Mode, Anti-Recall, Message History, and Client Enhancements  
**Reference Benchmark:** AyuGram / ExeGram Architecture (Desktop & iOS)  
**Target Platform:** Native iOS (TDLib Core + SwiftUI)  

---

## 1. Executive Overview

AyuGram is a modified Telegram client fork popular for two main capabilities:
1. **Ghost Mode:** The ability to read messages without sending read receipts, hide online status, and suppress typing indicators.
2. **Message History & Anti-Recall:** Saving deleted messages and message edit revisions locally so they remain visible to the user even after the sender purges or alters them.

This research analyzes how these features operate, their feasibility within official Telegram API & TDLib constraints, potential security/account ban risks, and safe implementations for **Project Yoru**.

---

## 2. Ghost Mode: Mechanics, Constraints & Risks

### How AyuGram Implements Ghost Mode
In standard Telegram clients, reading and interacting triggers specific network calls:
- Opening a chat calls `messages.readHistory` (MTProto) or `openChat` / `viewMessages` (TDLib).
- Typing in the input box transmits `messages.setTyping` or `sendChatAction(action: chatActionTyping)`.
- Staying connected sends periodic `account.updateStatus(offline: false)` pulses.

AyuGram intercepts these functions at the network dispatch layer:
- **Read Receipt Suppression:** Suppresses outgoing `viewMessages` or modifies the `max_id` parameter to not advance the server's read pointer.
- **Typing Suppression:** Discards `sendChatAction` calls whenever the corresponding preference toggle is active.
- **Offline Status Spoofing:** Drops periodic presence updates or immediately requests offline status via `account.updateStatus(offline: true)`.

### TDLib Architectural Constraints
Unlike custom C++ forks of Telegram Desktop that modify raw MTProto packet encoders, standard TDLib clients communicate with TDLib via high-level JSON:
1. When `openChat` is sent to TDLib, TDLib automatically manages the chat's read inbox marker and downloads messages.
2. In pure TDLib, `viewMessages` is triggered automatically unless the client explicitly handles message viewing via custom parameters or bypasses `openChat` by using `getChatHistory` in an "unopened" state.
3. **Important Limitation:** If a client never sends `viewMessages`, the messages remain unread across all other devices associated with the same Telegram account (e.g., Telegram Desktop, Web, or official iPhone app).

### Telegram API Restrictions & Ban Vectors
- **Protocol Anomaly Detection:** While Telegram historically tolerates third-party clients, aggressive protocol manipulation (such as sending messages in a chat without ever viewing earlier messages, or attempting to spoof official Telegram Premium server flags) can trigger automated anti-abuse scrutiny or rate-limiting (`429 FLOOD_WAIT`).
- **End-to-End Consistency:** Telegram's server architecture enforces message sequence numbering. Suppressing read receipts is client-side only; once an action (like sending a reply) is dispatched, Telegram servers inherently infer that earlier messages were received.

### Yoru's Supported Alternative: "Stealth Mode"
Rather than breaking protocol compliance, Yoru introduces **Stealth Mode**:
1. **Typing Indicator Suppression (100% Safe):** Disables sending `chatActionTyping` or `chatActionRecordingVoice`. Telegram API fully allows not sending typing indicators.
2. **Incognito Chat Previews (100% Safe):** Allows peeking and reading recent messages using `getChatHistory` without calling `openChat`, preventing the unread count from clearing until the user explicitly taps "Mark as Read".
3. **Scheduled Read Receipts:** An optional toggle where read markers are only sent upon active user confirmation or when a reply is dispatched.

---

## 3. Message History & Anti-Recall: Mechanics & Privacy

### How AyuGram Preserves Deleted Messages
When a user deletes a message for everyone in Telegram:
1. The Telegram server broadcasts `updateDeleteMessages` containing an array of message IDs.
2. Standard clients immediately delete these message rows from local SQLite storage (`messages.db`) and remove them from the UI.
3. AyuGram intercepts `updateDeleteMessages`. Instead of issuing a `DELETE FROM messages` SQL query, it executes:
   ```sql
   UPDATE messages SET is_deleted = 1, deleted_at = CURRENT_TIMESTAMP WHERE id IN (?);
   ```
4. The message remains visible in AyuGram with a visual indicator (e.g. red trash icon or `[DELETED]` tag).

### Similarly for Message Edits:
When a sender edits a message, Telegram broadcasts `updateEditMessage`. AyuGram saves the old message content to a separate `message_revisions` table before updating the primary record.

### Feasibility in Yoru
In Yoru, this can be implemented through a **`MessageHistoryVault`** actor:
- When incoming messages arrive via `TDLibJsonClient`, Yoru caches their metadata and text in an encrypted local database.
- When `updateDeleteMessages` is received from TDLib, Yoru flags the message as `.deletedLocally` rather than purging it from memory.
- In `MessageBubbleView`, deleted messages are rendered with an anime-themed **`[DELETED // 削除済]`** indicator with subtle strikethrough or red hue.

### Privacy & Legal Implications
1. **User Expectation vs Reality:** If a sender revokes a sensitive message (e.g., passwords, personal information, or private media), retaining it locally overrides their deletion intent.
2. **Data Protection (GDPR / CCPA):** If an app synchronizes or exports retained deleted messages to external cloud services, it directly violates privacy regulations.
3. **Yoru's Strict Rule:** In Yoru, Anti-Recall is strictly:
   - **Opt-in only** with explicit user consent in Yoru Labs.
   - **Local device only:** Never synced to external servers or telemetry.
   - **Securely encrypted:** Stored using the same AES-256 Keychain-backed key as TDLib.
   - **Self-Destruct Compliance:** Messages with a Telegram TTL (self-destruct timer) or in Secret Chats **MUST NOT** be retained after their timer expires.

---

## 4. Summary Matrix of AyuGram Features for Yoru Labs

| Feature | AyuGram Implementation | Yoru Labs Architecture | Protocol Safety | Status in Yoru |
|---|---|---|---|---|
| **Ghost Mode (Typing)** | Drops `sendChatAction` | `StealthModeEngine` drops typing packet | **100% Protocol Safe** | **Implemented** |
| **Ghost Mode (Read Receipts)** | Drops `viewMessages` | Incognito Previews (`getChatHistory` peek) | **Safe & Supported** | **Implemented** |
| **Anti-Recall (Deleted Msgs)** | SQL intercept on `updateDeleteMessages` | `MessageHistoryVault` encrypted local cache | **Local Only / Safe** | **Implemented** |
| **Edit History Tracking** | Multi-revision table | `MessageHistoryVault` revision stack | **Local Only / Safe** | **Implemented** |
| **Streamer Mode** | Regex string masking in GUI | `StreamerModeFilter` masks PII & numbers | **100% Client-Side** | **Implemented** |
| **Message Filters** | Custom keyword regex drops | `MessageFilterEngine` keyword/regex masking | **100% Client-Side** | **Implemented** |
| **Send Confirmations** | Dialog before send | SwiftUI confirmation alerts on send | **100% Client-Side** | **Implemented** |
| **Biometric App Lock** | PIN / TouchID lock | `LocalAuthentication` Face ID / Touch ID | **100% Native iOS** | **Implemented** |
