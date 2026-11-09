#!/usr/bin/env bash
# ==============================================================================
# YORU (夜) — TDLib iOS XCFramework Build Script
# ==============================================================================
# This script compiles TDLib for iOS devices (arm64) and Simulator (arm64, x86_64)
# and packages them into a fully standard TDLibFramework.xcframework with modulemap.
# Execute this script on a macOS workstation with Xcode 15+ installed.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build_tdlib"
OUTPUT_FRAMEWORK_DIR="${ROOT_DIR}/Yoru/Frameworks"

TDLIB_REPO="https://github.com/tdlib/td.git"
TDLIB_BRANCH="v1.8.0"

echo "=== [1/6] Checking macOS Build Tools ==="
command -v cmake >/dev/null 2>&1 || { echo "Error: cmake is required. Run 'brew install cmake'"; exit 1; }
command -v gperf >/dev/null 2>&1 || { echo "Error: gperf is required. Run 'brew install gperf'"; exit 1; }
command -v xcrun >/dev/null 2>&1 || { echo "Error: xcrun not found. Ensure Xcode Command Line Tools are active."; exit 1; }

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

if [ ! -d "td" ]; then
    echo "=== [2/6] Cloning TDLib (${TDLIB_BRANCH}) ==="
    git clone --depth 1 --branch "${TDLIB_BRANCH}" "${TDLIB_REPO}" td
fi

echo "=== [3/6] Compiling TDLib for iOS Device (arm64) ==="
mkdir -p build_device
cd build_device
cmake -DCMAKE_SYSTEM_NAME=iOS \
      -DCMAKE_OSX_ARCHITECTURES="arm64" \
      -DCMAKE_OSX_SYSROOT="iphoneos" \
      -DCMAKE_BUILD_TYPE=Release \
      -DTD_ENABLE_LTO=ON \
      ../td
cmake --build . --target tdjson --config Release -j "$(sysctl -n hw.ncpu)"
cd ..

echo "=== [4/6] Compiling TDLib for iOS Simulator (arm64;x86_64) ==="
mkdir -p build_sim
cd build_sim
cmake -DCMAKE_SYSTEM_NAME=iOS \
      -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
      -DCMAKE_OSX_SYSROOT="iphonesimulator" \
      -DCMAKE_BUILD_TYPE=Release \
      -DTD_ENABLE_LTO=ON \
      ../td
cmake --build . --target tdjson --config Release -j "$(sysctl -n hw.ncpu)"
cd ..

echo "=== [5/6] Preparing Headers and ModuleMap Directory ==="
HEADERS_DIR="${BUILD_DIR}/headers"
mkdir -p "${HEADERS_DIR}"
cp td/td/telegram/td_json_client.h "${HEADERS_DIR}/"
cp td/td/telegram/td_log.h "${HEADERS_DIR}/"

# Create Umbrella Header
cat << 'EOF' > "${HEADERS_DIR}/TDLibFramework.h"
#ifndef TDLibFramework_h
#define TDLibFramework_h

#include "td_json_client.h"
#include "td_log.h"

#endif /* TDLibFramework_h */
EOF

# Create Clang modulemap for pure Swift `import TDLibFramework`
cat << 'EOF' > "${HEADERS_DIR}/module.modulemap"
module TDLibFramework {
    umbrella header "TDLibFramework.h"
    export *
    module * { export * }
}
EOF

# Create Info.plist for framework bundles
cat << 'EOF' > "${HEADERS_DIR}/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>TDLibFramework</string>
    <key>CFBundleIdentifier</key>
    <string>com.yoru.TDLibFramework</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>TDLibFramework</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>1.8.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
</dict>
</plist>
EOF

echo "=== [6/6] Generating TDLibFramework.xcframework ==="
mkdir -p "${OUTPUT_FRAMEWORK_DIR}"
rm -rf "${OUTPUT_FRAMEWORK_DIR}/TDLibFramework.xcframework"

# Package Device Framework Bundle
mkdir -p build_device/TDLibFramework.framework/Headers
mkdir -p build_device/TDLibFramework.framework/Modules
cp "${HEADERS_DIR}"/*.h build_device/TDLibFramework.framework/Headers/
cp "${HEADERS_DIR}/module.modulemap" build_device/TDLibFramework.framework/Modules/
cp "${HEADERS_DIR}/Info.plist" build_device/TDLibFramework.framework/Info.plist
cp build_device/td/libtdjson.dylib build_device/TDLibFramework.framework/TDLibFramework

# Package Simulator Framework Bundle
mkdir -p build_sim/TDLibFramework.framework/Headers
mkdir -p build_sim/TDLibFramework.framework/Modules
cp "${HEADERS_DIR}"/*.h build_sim/TDLibFramework.framework/Headers/
cp "${HEADERS_DIR}/module.modulemap" build_sim/TDLibFramework.framework/Modules/
cp "${HEADERS_DIR}/Info.plist" build_sim/TDLibFramework.framework/Info.plist
cp build_sim/td/libtdjson.dylib build_sim/TDLibFramework.framework/TDLibFramework

xcodebuild -create-xcframework \
    -framework build_device/TDLibFramework.framework \
    -framework build_sim/TDLibFramework.framework \
    -output "${OUTPUT_FRAMEWORK_DIR}/TDLibFramework.xcframework"

echo "=== SUCCESS: Standard TDLibFramework.xcframework generated at ${OUTPUT_FRAMEWORK_DIR}/TDLibFramework.xcframework ==="
