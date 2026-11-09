# YORU (夜) — Security & Privacy Architecture

Security, privacy, and integrity are foundational principles of the Yoru client. Yoru strictly complies with the Telegram API Terms of Service, iOS Security Guidelines, and modern cryptographic best practices.

---

## 1. Zero-Trust Local Storage & Secret Protection

### Keychain Architecture
All persistent security artifacts are protected by the iOS Data Protection API and Hardware Secure Enclave:
- **TDLib Database Encryption Key:** A 256-bit cryptographically secure pseudorandom key (generated via `SecRandomCopyBytes`). It is written to the iOS Keychain with attribute:
  `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`. This ensures the local TDLib SQLite database cannot be extracted or deciphered even if a physical device backup is analyzed without the device passcode.
- **Session Tokens & Auth Keys:** Auth session states are managed directly by TDLib's internal encrypted vault. No plaintext authorization tokens, MTProto auth keys, or phone verification codes are ever written to `UserDefaults` or standard disk files.

### Memory Hygiene
- Sensitive buffers (login code digits, two-factor authentication password strings) are kept in localized, transient state variables and purged immediately once dispatched to the Telegram authentication pipeline.
- Swift `SecureString` structures zero out underlying memory buffers upon deinitialization.

---

## 2. API Key Protection & Anti-Harvesting

- **Credential Isolation:** The developer's Telegram `api_id` and `api_hash` are injected via build-time configuration files (`Config.xcconfig`) and never hardcoded in source control.
- **Zero Third-Party Telemetry:** Yoru contains zero tracking SDKs, zero third-party analytics trackers (no Google Analytics, Facebook SDK, Adjust, or Firebase telemetry). All network communication routes exclusively to official Telegram Core Datacenters (MTProto / TDLib IP ranges).
- **Anti-Scraping / Anti-Harvesting:** Yoru will never implement unauthorized mass contact harvesting, account dumping, or spam propagation tools.

---

## 3. Telegram API Compliance & Fair Use

- **No Fake Premium Emulation:** Yoru does not spoof Telegram Premium badges, force-unlock paid sticker packs without authorization, or inject fabricated server features.
- **Fair Rate-Limiting:** Adheres to Telegram FloodWait regulations (`429 FLOOD_WAIT_X`), gracefully scheduling backoffs without hammering Telegram servers.
- **Read & Typing Status Transparency:** Yoru does not implement illicit "ghost mode" hacks that violate Telegram protocol consistency or falsify read receipts.
- **Official Open-Source License Compatibility:** TDLib is licensed under the Boost Software License 1.0, enabling static and dynamic linkage in proprietary and open-source applications without licensing friction.
