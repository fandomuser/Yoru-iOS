# YORU (夜) — Codebase Audit & Technical Evaluation

**Audit Date:** November 10, 2026  
**Auditor:** Lead iOS Architect & Security Engineer  
**Workspace:** `c:\Users\Arif\Downloads\yoru`  
**Current State:** 73 Verified Source Files • Swift 5.10 / Swift 6 Mode  

---

## 1. Executive Summary

This audit assesses the actual Swift implementation across the codebase, identifying compilation risks, architectural boundaries, mock dependencies, and security compliance before introducing the **Yoru Labs** subsystem.

The codebase implements a clean, layered SwiftUI + Swift Concurrency architecture. However, several concrete compilation risks in the Swift Package Manager (SPM) dependency graph, missing explicit framework imports, and clear distinctions between mock and native implementations must be addressed.

---

## 2. Identified Compilation Risks & Target Graph Deficiencies

### Issue 2.1: Target Dependency Missing in `Package.swift`
- **Location:** `Package.swift` lines 27–30
- **Finding:** Target `YoruComponents` is configured with dependency:
  ```swift
  .target(
      name: "YoruComponents",
      dependencies: ["YoruCore"],
      path: "Yoru/Components"
  )
  ```
  However, component files directly reference Telegram domain models:
  - `ProfileCard.swift` references `TelegramUser`
  - `MessageBubbleView.swift` references `TelegramMessage` and `MessageReaction`
  - `CustomTabBar.swift` references `UnreadBadge`
  These domain models reside in `YoruTelegram`.
- **Severity:** High (SPM target build failure).
- **Remediation:** Add `YoruTelegram` to `YoruComponents` dependencies in `Package.swift`, and add explicit `import YoruTelegram` where necessary.

### Issue 2.2: `@Observable` Import Resolution Across Toolchains
- **Location:** Multiple files (`ThemeManager.swift`, `AppState.swift`, `TelegramService.swift`, and all ViewModels).
- **Finding:** The Swift Observation framework macro `@Observable` requires `import Observation`. In some Xcode configurations, `import SwiftUI` re-exports `Observation`, but in standalone SPM builds or command-line toolchains, missing explicit `import Observation` can trigger `cannot find macro 'Observable' in scope`.
- **Severity:** Medium.
- **Remediation:** Explicitly add `import Observation` to all `@Observable` types.

### Issue 2.3: `@Bindable` Declaration Scope in `AppCoordinator.swift`
- **Location:** `Yoru/App/AppCoordinator.swift`
- **Finding:** Declaring `@Bindable var state = appState` inside a computed property (`var mainAuthenticatedView: some View`) can cause compiler warnings or lifetime issues depending on Swift compiler strictness.
- **Severity:** Low.
- **Remediation:** Pass `@Bindable` cleanly via `@State private var appState = AppState.shared` or bind directly on properties.

---

## 3. Mock-Only vs Native Functional Audit

| Subsystem | File / Component | Status | Operational Capability | Notes |
|---|---|---|---|---|
| **Theme Engine** | `ThemeManager.swift`, `Themes.swift` | **Native (Production)** | 100% Functional | Full real-time switching across 5 themes, persistent via `UserDefaults`. |
| **Security Vault** | `KeychainService.swift`, `SecureStorage.swift` | **Native (Production)** | 100% Functional | Uses Apple `Security` framework (`kSecClassGenericPassword`, `SecRandomCopyBytes`). |
| **Atomic UI** | `YoruButton`, `YoruTextField`, `CyberCard`, etc. | **Native (Production)** | 100% Functional | Pure SwiftUI with custom shader modifiers and glassmorphic math. |
| **TDLib Low-Level** | `TDLibBridge.swift`, `TDLibJsonClient.swift` | **Native (Conditional)** | Functional when linked | Wraps standard TDLib C JSON functions (`td_json_client_*`); uses `#if canImport(TDLibFramework)` to prevent simulator breakage. |
| **Telegram Data** | `MockTelegramClient.swift` | **Mock (Preview/Dev)** | In-Memory Simulation | Emulates auth flow, pre-populates Persona/Syndicate anime chats for offline testing. |
| **Voice Playback** | `MessageBubbleView.swift` | **UI Skeleton** | Visual Only | Displays static waveform; lacks `AVAudioPlayer` streaming. |
| **Media Capture** | `ChatInputField.swift` | **UI Skeleton** | Trigger Only | Buttons present; `PhotosPicker` and camera sheet not yet attached. |

---

## 4. Architectural Readiness for Yoru Labs

To support AyuGram-inspired advanced features (Ghost Mode, Anti-Recall, Message Filtering, Streamer Mode, and Translation) without degrading Telegram protocol stability:
1. **Separation of Concerns:** Yoru Labs settings must not mutate core TDLib communication channels directly; they must act as an interception and presentation filter layer (`YoruLabsManager`).
2. **Account Scoping:** Settings must support both global defaults (e.g. Streamer Mode, Theme, Biometrics) and per-account overrides (e.g. Chat history retention, specific filter rules).
3. **Zero Crash Guarantee:** When a feature relies on unsupported API behavior (e.g., suppressing server-side read states), it must be clearly marked as experimental with fallback mechanisms.
