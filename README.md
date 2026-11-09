# YORU (夜) — Custom Anime Telegram Client for iOS

<p align="center">
  <img src="Yoru/Resources/Assets.xcassets/AppIcon.appiconset/icon_512.png" width="128" height="128" alt="Yoru App Icon" style="border-radius: 28px;" />
</p>

<p align="center">
  <strong>A high-performance, native iOS Telegram client crafted in Swift & SwiftUI with a Japanese Cyber-Anime aesthetic.</strong>
</p>

<p align="center">
  <a href="#key-features">Key Features</a> •
  <a href="#visual-themes">Visual Themes</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#security">Security</a> •
  <a href="#license">License</a>
</p>

---

## Key Features

- **True Native iOS Client:** Built natively in Swift and modern SwiftUI for iOS 17.0+ (engineered and optimized for the iPhone 17 Pro Max display and 120Hz ProMotion).
- **Official TDLib Engine:** Communicates directly with the official Telegram network using Telegram's Database Library (TDLib), supporting direct MTProto encryption and official protocols.
- **Anime Aesthetic Engine:** Completely original Japanese cyber-anime visual identity featuring custom glassmorphic panels, neon glow shaders, cybernetic HUD borders, and original vector empty states.
- **5 High-Contrast Built-in Themes:**
  1. 🌌 **Tokyo Night** (Default): Deep charcoal, dark slate, electric violet, and cyan accents.
  2. 🌸 **Sakura Dream**: Soft blossom pink, frosted glass, and delicate rose gold highlights.
  3. ⚡ **Midnight Blue**: Deep naval abyss, stark cobalt, and electric cyan neon.
  4. 🩸 **Crimson Moon**: Dark scarlet, obsidian black, and striking blood-red luminescence.
  5. 🖤 **Manga Mono**: High-contrast screentone-inspired black, white, and ink grays.
- **Rich Messaging Experience:** Text, dynamic photo cards, voice note playback visualizer, sticker/GIF support, pinned conversations, and instant unread badge syncing.
- **Dual-Mode Telegram Engine:** Transparent switching between production `TDLibClient` and an offline `MockTelegramClient` for development, UI previewing, and automated testing.

---

## Visual Themes

| Theme Name | Dominant Background | Primary Accent | Secondary Accent | Vibe |
|---|---|---|---|---|
| **Tokyo Night** | `#0D0E15` | Electric Violet (`#9D4EDD`) | Cyber Cyan (`#00F5D4`) | Neo-Tokyo Cyberpunk |
| **Sakura Dream** | `#1A141A` | Blossom Pink (`#FF70A6`) | Soft Rose (`#FF9770`) | Ethereal Anime Spring |
| **Midnight Blue** | `#080E1A` | Pure Cyan (`#00E8FC`) | Deep Cobalt (`#2E67F8`) | Futuristic Mecha HUD |
| **Crimson Moon** | `#12090C` | Crimson Scarlet (`#FF1E56`) | Solar Ember (`#FFAC41`) | Dark Fantasy / Eclipse |
| **Manga Mono** | `#0A0A0A` | Pure White (`#FFFFFF`) | Silver Tone (`#B0B0B0`) | Shonen / Seinen Manga Inks |

---

## Architecture Overview

Yoru follows a clean **Model-View-ViewModel (MVVM)** pattern combined with Swift Concurrency (`async`/`await`, `Actor` isolation, and `AsyncStream` event broadcasting).

```
[SwiftUI Views] ──► [ViewModels] ──► [TelegramService] ──► [TelegramClientProtocol]
                                                                  ▲          ▲
                                                                  │          │
                                                         [TDLibClient]   [MockClient]
```

- **TelegramService**: The unified Swift domain interface.
- **TelegramClientProtocol**: Decouples UI code from TDLib C bindings.
- **KeychainService**: Ensures zero plain-text storage of credentials or encryption keys.

---

## Getting Started

Refer to [BUILD.md](file:///c:/Users/Arif/Downloads/yoru/BUILD.md) for full macOS/Xcode setup, TDLib compiling, and code signing steps.

### Quick Start for Developers
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/yoru.git
   cd yoru
   ```
2. Configure your Telegram API credentials:
   ```bash
   cp Yoru/Resources/Config.xcconfig.template Yoru/Resources/Config.xcconfig
   ```
3. Open `Yoru.xcodeproj` in Xcode on macOS, or inspect the modular Swift packages on Windows.
4. Set scheme to **Yoru**, select **iPhone 17 Pro Max**, and hit **Run**.

---

## Security and Terms

Yoru strictly adheres to Telegram's [Terms of Service](https://core.telegram.org/api/terms) and Privacy Principles.
See [SECURITY.md](file:///c:/Users/Arif/Downloads/yoru/SECURITY.md) for detailed privacy and compliance documentation.

---

## License

Yoru is released under the MIT License. TDLib is licensed under the Boost Software License 1.0.
