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
TDLIB_PINNED_SHA256="c86ca527be4adb4e2562693176b28a74290a86e9a55988af5c169420c6b77d49"
MINIMUM_EXPECTED_BINARY_BYTES=10000000  # Real TDLib binary slice is >10MB; stubs are <50KB
PROVENANCE_RECEIPT="${OUTPUT_DIR}/.provenance_receipt"

echo "=== [1/5] Verifying Target Directory & Cryptographic Provenance ==="
mkdir -p "${ROOT_DIR}/Yoru/Frameworks"

if [ -d "${OUTPUT_DIR}" ] && [ -f "${OUTPUT_DIR}/Info.plist" ] && [ -f "${PROVENANCE_RECEIPT}" ]; then
    RECORDED_HASH=$(cat "${PROVENANCE_RECEIPT}" | tr -d ' \n\r')
    if [ "${RECORDED_HASH}" = "${TDLIB_PINNED_SHA256}" ]; then
        echo "[+] TDLibFramework.xcframework with verified cryptographic provenance (${RECORDED_HASH}) is already installed."
        exit 0
    else
        echo "[!] Existing framework provenance hash mismatch (${RECORDED_HASH} != ${TDLIB_PINNED_SHA256}). Re-downloading..."
        rm -rf "${OUTPUT_DIR}"
    fi
else
    if [ -d "${OUTPUT_DIR}" ]; then
        echo "[!] Existing framework lacks verified cryptographic provenance receipt. Re-downloading and validating pinned release..."
        rm -rf "${OUTPUT_DIR}"
    fi
fi

echo "=== [2/5] Downloading Official Pinned TDLib Release (${TDLIB_PINNED_VERSION}) ==="
TMP_ZIP="${ROOT_DIR}/Yoru/Frameworks/TDLibFramework_${TDLIB_PINNED_VERSION}.zip"
trap 'rm -f "${TMP_ZIP}"' EXIT

curl -L --fail --retry 3 --retry-delay 2 -o "${TMP_ZIP}" "${TDLIB_RELEASE_URL}" || {
    echo "[!] CRITICAL ERROR: Failed to download official TDLib binary from ${TDLIB_RELEASE_URL}."
    echo "[!] CI/Build cannot proceed without real TDLib dependency."
    exit 1
}

echo "=== [3/5] Verifying SHA-256 Cryptographic Checksum ==="
if command -v shasum >/dev/null 2>&1; then
    ACTUAL_SHA256=$(shasum -a 256 "${TMP_ZIP}" | awk '{print $1}')
elif command -v sha256sum >/dev/null 2>&1; then
    ACTUAL_SHA256=$(sha256sum "${TMP_ZIP}" | awk '{print $1}')
else
    echo "[!] CRITICAL ERROR: Neither shasum nor sha256sum is available on this system."
    echo "[!] Cannot cryptographically verify the integrity of the downloaded TDLib archive."
    exit 1
fi

if [ "${ACTUAL_SHA256}" != "${TDLIB_PINNED_SHA256}" ]; then
    echo "[!] CRITICAL ERROR: SHA-256 Checksum Mismatch!"
    echo "    Expected: ${TDLIB_PINNED_SHA256}"
    echo "    Actual:   ${ACTUAL_SHA256}"
    exit 1
fi
echo "[+] Cryptographic Integrity Verified: SHA-256 matches official release (${ACTUAL_SHA256})."

echo "=== [4/5] Unpacking TDLibFramework.xcframework ==="
rm -rf "${OUTPUT_DIR}"
unzip -q -o "${TMP_ZIP}" -d "${ROOT_DIR}/Yoru/Frameworks/" || {
    echo "[!] CRITICAL ERROR: Failed to extract ${TMP_ZIP}."
    exit 1
}

echo "=== [5/5] Validating Production Framework Integrity and Layout ==="
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

# Validate modulemap and module identity
MODULEMAP_FILE=$(find "${OUTPUT_DIR}" -name "module.modulemap" | head -n 1)
if [ -n "${MODULEMAP_FILE}" ] && [ -f "${MODULEMAP_FILE}" ]; then
    if grep -q "module TDLibFramework" "${MODULEMAP_FILE}"; then
        echo "[+] Clang modulemap validated: exports 'module TDLibFramework'."
    else
        echo "[!] Warning: module.modulemap does not contain 'module TDLibFramework'."
    fi
fi

# Write cryptographic provenance receipt into extracted framework
echo "${TDLIB_PINNED_SHA256}" > "${PROVENANCE_RECEIPT}"
echo "[+] Cryptographic provenance receipt recorded at ${PROVENANCE_RECEIPT}."

echo "[+] SUCCESS: Real official TDLibFramework.xcframework installed and verified (${BINARY_SIZE} bytes) at ${OUTPUT_DIR}."
