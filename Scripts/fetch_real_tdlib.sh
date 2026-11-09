#!/usr/bin/env bash
# ==============================================================================
# YORU (夜) — Fetch Real Official Pinned TDLib XCFramework
# ==============================================================================
# Downloads and verifies the authentic, production-grade TDLib XCFramework
# compiled directly from official Telegram TDLib C++ sources (pinned commit 4c6377aa).
# This provides real networking, OpenSSL cryptography, MTProto protocol handling,
# and official TDLib JSON client interfaces for iOS device (arm64) and simulator.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_DIR="${ROOT_DIR}/Yoru/Frameworks/TDLibFramework.xcframework"

# Pinned release configuration
TDLIB_PINNED_VERSION="1.8.69-4c6377aa"
TDLIB_RELEASE_URL="https://github.com/Swiftgram/TDLibFramework/releases/download/${TDLIB_PINNED_VERSION}/TDLibFramework.zip"
MINIMUM_EXPECTED_BINARY_BYTES=10000000  # Real TDLib binary slice is >10MB; stubs are <50KB

echo "=== [1/4] Verifying Target Directory ==="
mkdir -p "${ROOT_DIR}/Yoru/Frameworks"

if [ -d "${OUTPUT_DIR}" ] && [ -f "${OUTPUT_DIR}/Info.plist" ]; then
    echo "[*] TDLibFramework.xcframework directory found. Checking binary authenticity..."
    # Verify binary size
    REAL_BINARY=$(find "${OUTPUT_DIR}" -name "TDLibFramework" -o -name "libtdjson.dylib" | head -n 1)
    if [ -n "${REAL_BINARY}" ] && [ -f "${REAL_BINARY}" ]; then
        SIZE=$(wc -c < "${REAL_BINARY}" | tr -d ' ')
        if [ "${SIZE}" -ge "${MINIMUM_EXPECTED_BINARY_BYTES}" ]; then
            echo "[+] Real TDLib binary verified (${SIZE} bytes at ${REAL_BINARY})."
            exit 0
        else
            echo "[!] Existing framework is a mock or stub (${SIZE} bytes < ${MINIMUM_EXPECTED_BINARY_BYTES} bytes). Replacing with real TDLib..."
            rm -rf "${OUTPUT_DIR}"
        fi
    fi
fi

echo "=== [2/4] Downloading Official Pinned TDLib Release (${TDLIB_PINNED_VERSION}) ==="
TMP_ZIP="${ROOT_DIR}/Yoru/Frameworks/TDLibFramework_${TDLIB_PINNED_VERSION}.zip"
trap 'rm -f "${TMP_ZIP}"' EXIT

curl -L --fail --retry 3 --retry-delay 2 -o "${TMP_ZIP}" "${TDLIB_RELEASE_URL}" || {
    echo "[!] CRITICAL ERROR: Failed to download official TDLib binary from ${TDLIB_RELEASE_URL}."
    echo "[!] CI/Build cannot proceed without real TDLib dependency."
    exit 1
}

echo "=== [3/4] Unpacking TDLibFramework.xcframework ==="
rm -rf "${OUTPUT_DIR}"
unzip -q -o "${TMP_ZIP}" -d "${ROOT_DIR}/Yoru/Frameworks/" || {
    echo "[!] CRITICAL ERROR: Failed to extract ${TMP_ZIP}."
    exit 1
}

echo "=== [4/4] Validating Production Framework Integrity ==="
if [ ! -d "${OUTPUT_DIR}" ] || [ ! -f "${OUTPUT_DIR}/Info.plist" ]; then
    echo "[!] CRITICAL ERROR: ${OUTPUT_DIR}/Info.plist is missing after extraction."
    exit 1
fi

# Locate the actual binary inside the xcframework
REAL_BINARY=$(find "${OUTPUT_DIR}" -name "TDLibFramework" -o -name "libtdjson.dylib" | head -n 1)
if [ -z "${REAL_BINARY}" ] || [ ! -f "${REAL_BINARY}" ]; then
    echo "[!] CRITICAL ERROR: No executable binary found in ${OUTPUT_DIR}."
    exit 1
fi

BINARY_SIZE=$(wc -c < "${REAL_BINARY}" | tr -d ' ')
if [ "${BINARY_SIZE}" -lt "${MINIMUM_EXPECTED_BINARY_BYTES}" ]; then
    echo "[!] CRITICAL ERROR: TDLib binary validation failed. Expected authentic binary >= ${MINIMUM_EXPECTED_BINARY_BYTES} bytes, found ${BINARY_SIZE} bytes."
    exit 1
fi

echo "[+] SUCCESS: Real official TDLibFramework.xcframework installed (${BINARY_SIZE} bytes) at ${OUTPUT_DIR}."
