#!/usr/bin/env bash
# ==============================================================================
# YORU (夜) — Automated iOS Simulator Screen Capture & Validation
# ==============================================================================
# Launches Yoru in the booted iOS Simulator, navigates deterministically
# through all key visual surfaces, and records real PNG screenshots and an MP4/GIF.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_DIR="${ROOT_DIR}/artifacts/screenshots"

mkdir -p "${OUTPUT_DIR}"

echo "=== [1/5] Discovering & Booting iOS Simulator ==="

# Check for existing booted simulator or pick/create one
BOOTED_ID=$(xcrun simctl list devices booted | grep -oE '\([A-F0-9-]+\)' | head -n 1 | tr -d '()' || true)

if [ -n "${BOOTED_ID}" ]; then
    DEVICE_ID="${BOOTED_ID}"
    echo "[+] Found already booted simulator: ${DEVICE_ID}"
else
    # Find available iPhone simulator device
    DEVICE_ID=$(xcrun simctl list devices available | grep -E "iPhone 16|iPhone 15|iPhone 14" | head -n 1 | grep -oE '\([A-F0-9-]+\)' | tr -d '()' || true)
    if [ -z "${DEVICE_ID}" ]; then
        echo "[*] Creating new iPhone simulator device for visual capture..."
        DEVICE_ID=$(xcrun simctl create "Yoru-Visual-Validation" "iPhone 16 Pro Max" "com.apple.CoreSimulator.SimRuntime.iOS-18-0" || xcrun simctl create "Yoru-Visual-Validation" "iPhone 15 Pro Max")
    fi
    echo "[+] Booting simulator: ${DEVICE_ID}"
    xcrun simctl boot "${DEVICE_ID}" || true
    xcrun simctl bootstatus "${DEVICE_ID}" -b
fi

echo "=== [2/5] Locating Built Yoru.app ==="
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Yoru.app" -type d | head -n 1 || true)

if [ -z "${APP_PATH}" ] || [ ! -d "${APP_PATH}" ]; then
    echo "[!] Error: Yoru.app bundle not found in DerivedData"
    exit 1
fi
echo "[+] Located Yoru.app at: ${APP_PATH}"

echo "=== [3/5] Installing Yoru.app to Simulator ==="
xcrun simctl install "${DEVICE_ID}" "${APP_PATH}"

echo "=== [4/5] Capturing Real Simulator Screenshots ==="

declare -a SCREENS=("onboarding" "login" "chatlist" "conversation" "settings" "labs" "themes")
declare -a FILE_NAMES=("01_onboarding" "02_login" "03_chat_list" "04_conversation" "05_settings" "06_yoru_labs" "07_theme_selector")

for i in "${!SCREENS[@]}"; do
    SCREEN="${SCREENS[$i]}"
    FILE_NAME="${FILE_NAMES[$i]}"
    echo "[*] Capturing '${SCREEN}' screen -> ${OUTPUT_DIR}/${FILE_NAME}.png"

    # Launch app with specific screen parameter
    xcrun simctl launch "${DEVICE_ID}" com.yoru.client -screen "${SCREEN}" >/dev/null 2>&1 || true
    sleep 3
    xcrun simctl io "${DEVICE_ID}" screenshot "${OUTPUT_DIR}/${FILE_NAME}.png"
    xcrun simctl terminate "${DEVICE_ID}" com.yoru.client >/dev/null 2>&1 || true
    sleep 1
done

echo "=== [5/5] Recording Simulator Navigation Walkthrough ==="
RECORD_MP4="${OUTPUT_DIR}/navigation.mp4"
RECORD_GIF="${OUTPUT_DIR}/navigation.gif"

xcrun simctl io "${DEVICE_ID}" recordVideo --codec=h264 "${RECORD_MP4}" &
REC_PID=$!
sleep 2

# Cycle through main views
for NAV_SCREEN in "chatlist" "conversation" "settings" "labs" "themes"; do
    echo "[*] Recording walkthrough: ${NAV_SCREEN}"
    xcrun simctl launch "${DEVICE_ID}" com.yoru.client -screen "${NAV_SCREEN}" >/dev/null 2>&1 || true
    sleep 2
    xcrun simctl terminate "${DEVICE_ID}" com.yoru.client >/dev/null 2>&1 || true
    sleep 1
done

kill -SIGINT "${REC_PID}" 2>/dev/null || true
sleep 3

if command -v ffmpeg &> /dev/null && [ -f "${RECORD_MP4}" ]; then
    echo "[+] Converting MP4 recording to animated GIF..."
    ffmpeg -y -i "${RECORD_MP4}" -vf "fps=8,scale=360:-1:flags=lanczos" "${RECORD_GIF}" || true
fi

echo "=== Visual Capture Complete ==="
ls -lh "${OUTPUT_DIR}"
