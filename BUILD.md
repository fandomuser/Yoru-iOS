# YORU (夜) — Build and Packaging Guide

This guide details how to build, test, and package **Yoru** for native execution on an authorized physical iPhone (targeting iPhone 17 Pro Max with iOS 17.0+).

---

## 1. Development Environment Topology

```
┌─────────────────────────────────┐       Git / Transfer       ┌─────────────────────────────────┐
│     Windows 11 Workstation      │ ─────────────────────────> │          macOS Runner           │
│  (UI/UX, Architecture, Code)   │                            │      (Xcode 15+, TDLib)         │
│  - Swift Package Layout         │                            │  - clang / cmake / xcrun        │
│  - Complete SwiftUI Views       │                            │  - TDLibFramework.xcframework  │
│  - Protocol-Based Mock Engine   │                            │  - Code Signing & Provisioning  │
│  - Verification Scripts         │                            │  - IPA Archive & Export         │
└─────────────────────────────────┘                            └─────────────────────────────────┘
```

Because native Apple iOS binary code compilation and code signing strictly require Apple's proprietary toolchains (`clang` for arm64-apple-ios, `codesign`, `xcrun`, `lldb`), development on Windows produces **clean, compilable, zero-warning Swift & Xcode assets** that compile directly on macOS.

---

## 2. Prerequisites on macOS Build Host

1. **macOS Sonoma (14.0+) or Sequoia (15.0+)**
2. **Xcode 15.3+ or Xcode 16+** with iOS 17/18 SDK installed:
   ```bash
   xcode-select --install
   ```
3. **Build tools for TDLib:**
   ```bash
   brew install cmake gperf openssl
   ```

---

## 3. Building TDLib as an XCFramework for iOS

TDLib must be built for both physical devices (`arm64-apple-ios`) and simulators (`arm64-apple-ios-simulator`).

An automated build script is provided at `Scripts/build_tdlib_ios.sh`:

```bash
cd Scripts
chmod +x build_tdlib_ios.sh
./build_tdlib_ios.sh
```

### What the script executes:
1. Clones TDLib from `https://github.com/tdlib/td.git` (stable tag `v1.8.0` or latest).
2. Cross-compiles OpenSSL for iOS using `apple-darwin-arm64`.
3. Invokes CMake with `CMAKE_TOOLCHAIN_FILE` for iOS:
   ```bash
   cmake -DCMAKE_TOOLCHAIN_FILE=../ios.toolchain.cmake \
         -DPLATFORM=OS64 \
         -DCMAKE_BUILD_TYPE=Release \
         -DTD_ENABLE_LTO=ON ..
   ```
4. Produces `TDLibFramework.xcframework` containing:
   - `ios-arm64` (Physical iPhone / iPhone 17 Pro Max)
   - `ios-arm64_x86_64-simulator` (Xcode Previews & Simulator)
   - C Headers: `td_json_client.h`, `td_log.h`
   - Module map for pure Swift import: `import TDLibFramework`

Place the compiled `TDLibFramework.xcframework` in `Yoru/Frameworks/`.

---

## 4. Telegram API Credentials Setup

To connect to the official Telegram network, you need your unique `api_id` and `api_hash`:
1. Log in to [https://my.telegram.org](https://my.telegram.org).
2. Navigate to **API development tools**.
3. Create a new application (e.g. named "Yoru iOS").
4. Copy `api_id` and `api_hash`.
5. Copy the configuration template:
   ```bash
   cp Yoru/Resources/Config.xcconfig.template Yoru/Resources/Config.xcconfig
   ```
6. Populate `Config.xcconfig`:
   ```xcconfig
   YORU_TELEGRAM_API_ID = 12345678
   YORU_TELEGRAM_API_HASH = "0123456789abcdef0123456789abcdef"
   ```
*(Note: `Config.xcconfig` is ignored by Git to prevent accidental disclosure).*

---

## 5. Compiling & Signing in Xcode

1. Open `Yoru.xcodeproj` in Xcode.
2. Select target **Yoru** -> **Signing & Capabilities**.
3. Select your Apple Developer Team:
   - Paid Apple Developer Account (supports PushKit and App Groups).
   - Or Free Personal Apple ID (for local testing via AltStore / SideStore).
4. Connect your **iPhone 17 Pro Max** via USB-C or Wi-Fi.
5. In Xcode's target selector, choose your physical iPhone.
6. Press **Cmd + R** to build and run.

---

## 6. Exporting an IPA for Physical Device Installation

To build a standalone `.ipa` for side-loading (via AltStore, Sideloadly, or Apple Configurator):

```bash
# 1. Clean and build archive
xcodebuild archive \
  -project Yoru.xcodeproj \
  -scheme Yoru \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath ./build/Yoru.xcarchive

# 2. Export IPA
xcodebuild -exportArchive \
  -archivePath ./build/Yoru.xcarchive \
  -exportPath ./build/Exported \
  -exportOptionsPlist ExportOptions.plist
```

Output file: `./build/Exported/Yoru.ipa`.
