# YORU (夜) — Architectural Specification

**Version:** 0.1.0-alpha  
**Platform:** iOS 17.0+ (Optimized for iPhone 17 Pro Max)  
**Language:** Swift 5.10 / Swift 6 Mode  
**UI Framework:** SwiftUI with Swift Concurrency  
**Network / Protocol Layer:** Telegram TDLib (Telegram Database Library) C/JSON Core via Async Swift Bridge  

---

## 1. System Overview

Yoru is a native iOS client for the Telegram network, engineered with a Japanese Cyber-Anime aesthetic (Tokyo Night, Sakura Dream, Midnight Blue, Crimson Moon, and Manga Mono). Unlike basic theme injectors or unofficial web wrappers, Yoru connects directly to Telegram's production infrastructure via **TDLib**, Telegram's battle-tested cross-platform engine.

### Core Architectural Principles
1. **Unidirectional Data Flow (MVVM + Observable Architecture):** Every screen is backed by an `@Observable` (or `ObservableObject`) ViewModel that observes clean domain models from the `TelegramService`.
2. **Protocol-Driven TDLib Isolation:** The SwiftUI presentation layer never imports or references low-level TDLib C pointers, JSON strings, or native bridge details. All Telegram capabilities are exposed via `TelegramClientProtocol`.
3. **Multi-Environment Resilience:** A dedicated `MockTelegramClient` provides realistic, deterministic Telegram data for SwiftUI Canvas Previews, unit testing, UI tests, and development on non-macOS workstations.
4. **Zero-Leak Security Boundary:** Cryptographic keys, Telegram API secrets, authorization tokens, and user encryption credentials reside strictly in memory or the iOS Keychain (`kSecClassGenericPassword` with `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`).

---

## 2. Layered Architecture

```
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│  SwiftUI Views • Modifiers • Cyber Animations • HUD    │
│  (ChatListView, ConversationView, AuthView, etc.)      │
└───────────────────────────▲────────────────────────────┘
                            │ Bindings & State
┌───────────────────────────┴────────────────────────────┐
│                    ViewModel Layer                     │
│  @Observable ViewModels • State Machines • Formatters  │
│  (AuthViewModel, ChatListViewModel, ThemeManager)     │
└───────────────────────────▲────────────────────────────┘
                            │ Async/Await & Streams
┌───────────────────────────┴────────────────────────────┐
│                  Service Domain Layer                  │
│       TelegramService (High-level Swift Domain API)     │
│       ThemeEngine • NotificationManager • Keychain     │
└───────────────────────────▲────────────────────────────┘
                            │ Conforms to
┌───────────────────────────┴────────────────────────────┐
│              Telegram Client Abstraction               │
│               TelegramClientProtocol                   │
├────────────────────────────┬───────────────────────────┤
│     TDLibClient (Real)     │  MockTelegramClient (Dev) │
│ - td_json_client bridge    │ - In-memory state store   │
│ - AsyncStream updates      │ - Deterministic mock data │
│ - JSON serialization       │ - Canvas preview provider │
└────────────────────────────┴───────────────────────────┘
                            │
┌───────────────────────────┴────────────────────────────┐
│             Hardware & Platform Subsystems             │
│   iOS Keychain • Security Enclave • PushKit • CoreData  │
│   TDLib C-Core (OpenSSL 3.x, zlib, SQLite 3.x)         │
└────────────────────────────────────────────────────────┘
```

---

## 3. TDLib Integration Pipeline

Telegram Database Library (TDLib) is designed around an asynchronous, message-passing client-server model over a JSON interface.

### The C JSON Client Bridge
TDLib exports 4 primary C functions:
- `void* td_json_client_create(void)`: Instantiates a client context.
- `void td_json_client_send(void* client, const char* request)`: Asynchronously dispatches a JSON request.
- `const char* td_json_client_receive(void* client, double timeout)`: Blocks for up to `timeout` seconds waiting for incoming updates or responses.
- `const char* td_json_client_execute(void* client, const char* request)`: Synchronously executes stateless queries (e.g., parsing deep links or client configuration).

### Swift Concurrency Actor Pipeline
To ensure thread-safety and zero main-thread hitching:
1. **`TDLibBridge` Actor:** Owns the raw client pointer (`UnsafeMutableRawPointer?`).
2. **Dedicated Ingestion Loop (Task with `.userInitiated` priority):**
   ```swift
   while !Task.isCancelled {
       if let cResponse = td_json_client_receive(rawPointer, 1.0) {
           let jsonString = String(cString: cResponse)
           updateStreamContinuation.yield(jsonString)
       }
   }
   ```
3. **Concurrent Query Router:** Every outgoing request attaches a unique `@extra` UUID. A thread-safe pending-response continuation dictionary routes the matching response back to the calling Swift `async` function.

---

## 4. State Management & Navigation

- **Navigation:** Coordinated via SwiftUI `NavigationStack` driven by type-safe `NavigationPath` and hashable destination enums (`AppRoute`).
- **Global App State:** `AppState` encapsulates session authorization state:
  - `.uninitialized`
  - `.waitingForPhoneNumber`
  - `.waitingForCode(type: AuthCodeType)`
  - `.waitingForPassword(hint: String?)`
  - `.ready(user: CurrentUser)`
  - `.closing`
  - `.closed`
- **Themes:** Managed via `ThemeManager`, publishing dynamic color tokens, glassmorphic blur radii, typography scales, and glow intensities to the SwiftUI environment.

---

## 5. Security & Isolation

Refer to [SECURITY.md](file:///c:/Users/Arif/Downloads/yoru/SECURITY.md) for full protocol verification rules.
- Telegram API secrets (`api_id`, `api_hash`) are injected at build-time via `.xcconfig` and encrypted bundle properties; never hardcoded in repository sources.
- TDLib database encryption key is randomly generated on first launch, stored in the iOS Keychain, and delivered to `td_set_database_encryption_key`.
