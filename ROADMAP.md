# YORU (夜) — Development Roadmap

Current Target: **iPhone 17 Pro Max (iOS 17.0+)**  
Architecture: **SwiftUI + Swift Concurrency + TDLib Protocol Bridge**

---

## Phase Status Summary

| Phase | Description | Status | Completion % |
|---|---|---|---|
| **Phase 1** | Research, Architecture & Build Blueprints | Completed | 100% |
| **Phase 2** | Project Foundation, Design System & Reusable Components | Completed | 100% |
| **Phase 3** | Core Interface Implementation (SwiftUI + Previews) | Completed | 100% |
| **Phase 4** | Telegram Integration (TDLib Engine & Mock Fallback) | In Progress | 80% |
| **Phase 5** | Yoru Labs & Advanced Client Extensions (AyuGram Engine) | In Progress | 90% |
| **Phase 6** | Quality Assurance, Unit/UI Tests & Security Audit | In Progress | 70% |
| **Phase 7** | macOS/Xcode Compilation, Signing & IPA Packaging | In Progress | 60% |

---

## Detailed Task Breakdown

### Phase 1: Research and Architecture
- [x] Research official TDLib C/JSON APIs and dynamic linking models for iOS.
- [x] Design multi-layer MVVM + Actor Concurrency architecture.
- [x] Author comprehensive project documentation:
  - [x] `ARCHITECTURE.md`
  - [x] `ROADMAP.md`
  - [x] `BUILD.md`
  - [x] `SECURITY.md`
  - [x] `README.md`

### Phase 2: Project Foundation & Design System
- [x] Create clean modular directory structure (`App`, `Core`, `Telegram`, `Components`, `Features`, `Resources`).
- [x] Build cyber-anime Design System:
  - [x] Color palette tokens (Tokyo Night, Sakura Dream, Midnight Blue, Crimson Moon, Manga Mono).
  - [x] Typography tokens (Kanji headings, monospaced metadata, sleek body).
  - [x] Custom glassmorphic, neon-glow, and cyber-border modifiers.
  - [x] Animation curves and reduced-motion fallbacks.
- [x] Build reusable atomic UI components:
  - [x] `YoruButton` (Cyber-cutout interactive buttons).
  - [x] `YoruTextField` (Neon underline and glowing icon inputs).
  - [x] `CustomTabBar` (Floating cyber-glass navigation bar).
  - [x] `YoruAvatarView` (Hexagonal & circular status avatars).
  - [x] `MessageBubbleView` (Custom tails, gradients, read states).
  - [x] `EmptyStateView` & `MangaGraphicView` (Original anime empty-state artwork).

### Phase 3: Interface Implementation
- [x] Onboarding Screen (Dynamic anime particle backdrop, introductory lore).
- [x] Authentication Flows:
  - [x] Phone Number Input (International dialing selector, cyber styling).
  - [x] Telegram Login Code Verification (Split-box digit inputs).
  - [x] Two-Step Verification Password Screen.
- [x] Chat List View:
  - [x] Chat Folders bar ("All", "Personal", "Channels", "Cyber Groups").
  - [x] Unread badges, online indicators, pinned chat pins, draft indicators.
- [x] Active Conversation View:
  - [x] Interactive header with contact status and anime avatar.
  - [x] Fluid message stream with timestamps, reactions, and read checks.
  - [x] Chat input console with voice, sticker, attachment, and send actions.
- [x] Settings & Theme Studio:
  - [x] Real-time theme switcher across all 5 themes.
  - [x] Bubble style customization and animation intensity controls.
- [x] User Profile View:
  - [x] Cyber ID card, bio, media gallery, notification toggles.
- [x] Global Search View:
  - [x] Instant filtering of chats, messages, and media.

### Phase 4: Telegram Integration
- [x] Protocol definition (`TelegramClientProtocol`) with full domain abstractions.
- [x] Comprehensive `MockTelegramClient` for previewing and local testing without binary dependencies.
- [x] `TDLibJsonClient` production actor implementing real TDLib requests (`getChats`, `getChatHistory`, `sendMessage`, `getMe`).
- [x] Real-time TDLib update stream routing (`updateNewChat`, `updateChatLastMessage`, `updateNewMessage`, `updateUserStatus`).
- [x] Strict error propagation via `TDLibError` with numerical code and descriptive message.
- [x] Cooperative task cancellation and receive-loop lifetime management.
- [x] Race-safe timeout mechanism enforcing `timeoutSeconds` with exactly-once continuation completion.
- [x] TDLib 1.8.x event-driven state machine (`authorizationStateWaitTdlibParameters` -> `setTdlibParameters` -> `authorizationStateWaitEncryptionKey` -> `checkDatabaseEncryptionKey` -> `authorizationStateWaitPhoneNumber`).
- [x] Database encryption API compatibility using `checkDatabaseEncryptionKey` with Keychain-derived key.
- [x] `TDLibFramework.xcframework` integration into `Yoru.xcodeproj` (`PBXFrameworksBuildPhase` and `Embed Frameworks`).
- [x] Authentic, production-grade TDLib binary fetch script (`Scripts/fetch_real_tdlib.sh`) pinned to official release `1.8.69-4c6377aa` (>10MB C++ engine with OpenSSL).
- [x] Automated Telegram Test DC integration test support (`use_test_dc: true` in `Tests/YoruTests.swift`).
- [ ] Connect full production compiled TDLib XCFramework on macOS build machine.
- [ ] Verify production auth loop against Telegram test servers (DC 2 / DC 5).

### Phase 5: Yoru Labs & Advanced Client Extensions (AyuGram Engine)
- [x] Comprehensive Swift Source Code Audit ([`AUDIT.md`](file:///c:/Users/Arif/Downloads/yoru/AUDIT.md)).
- [x] AyuGram-Inspired Ghost Mode & Anti-Recall Feasibility & Restriction Study ([`AYUGRAM_RESEARCH.md`](file:///c:/Users/Arif/Downloads/yoru/AYUGRAM_RESEARCH.md)).
- [x] Modular Yoru Labs architecture with global and per-account isolation:
  - [x] `YoruLabsSettings.swift`
  - [x] `YoruLabsStore.swift`
  - [x] `YoruLabsManager.swift`
- [x] 8 Yoru Labs Settings Modules & SwiftUI Interfaces:
  - [x] Privacy & Activity Settings (`PrivacyActivitySettingsView`)
  - [x] Message History & Anti-Recall Settings (`MessageHistorySettingsView`)
  - [x] Message Filters & Firewall Settings (`MessageFiltersSettingsView`)
  - [x] Appearance Customization Settings (`AppearanceCustomizationView`)
  - [x] Chat Enhancements Settings (`ChatEnhancementsSettingsView`)
  - [x] Translation Engine Settings (`TranslationSettingsView`)
  - [x] AI Tools & Neural Agents Settings (`AIToolsSettingsView`)
  - [x] Advanced & Streamer Mode Settings (`AdvancedSettingsView`)
- [x] Working Local Features:
  - [x] Real-time message filtering engine (keywords, regex patterns, spoiler blur, warning collapse).
  - [x] Dynamic message bubble radius linked to live slider.
  - [x] Avatar shape customization (Circle, Squircle, Hexagon, Cyber-Cut).
  - [x] Hidden UI elements (Hide phone numbers, hide usernames, hide floating reaction bar).
  - [x] Streamer Mode (Auto-masking phone numbers, usernames, and chat titles).
  - [x] Send confirmation safety gates (Channels, supergroups, voice message release).
  - [x] Local Face ID / Biometric lock protection with configurable auto-lock timeout.
  - [x] Custom interactive context menus on message bubbles (Copy, Reply, Translate, Reactions, Delete).
  - [x] Anti-Recall message vault actor retaining deleted messages with red `[DELETED // 削除済]` badge.
- [ ] Rich media streaming with waveform audio player.
- [ ] Background push notifications via APNs and PushKit.

### Phase 6: Quality Assurance
- [x] Security audit: Keychain storage verification, anti-logging enforcement.
- [x] Unit test suite for settings persistence, filtering, and per-account isolation ([`Tests/YoruLabsTests.swift`](file:///c:/Users/Arif/Downloads/yoru/Tests/YoruLabsTests.swift)).
- [x] Core state machine & Telegram mock client tests ([`Tests/YoruTests.swift`](file:///c:/Users/Arif/Downloads/yoru/Tests/YoruTests.swift)).
- [ ] Performance audit: 120Hz ProMotion verification on iPhone 17 Pro Max.
- [ ] Accessibility: Dynamic Type support and VoiceOver labels.

### Phase 7: iOS Distribution & Verification
- [x] Xcode `.xcodeproj` generation and schema validation.
- [x] Automated packaging shell script (`build_tdlib_ios.sh`).
- [ ] Developer profile code signing and provision profile injection.
- [ ] IPA creation guide for AltStore, SideStore, and TestFlight.
