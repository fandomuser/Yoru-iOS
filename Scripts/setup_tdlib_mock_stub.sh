#!/usr/bin/env bash
# ==============================================================================
# YORU (夜) — Offline Compilation Stub: TDLibMock.xcframework ONLY
# ==============================================================================
# WARNING: This script generates TDLibMock.xcframework. It is ONLY for offline,
# compile-only testing in environments without network connectivity.
# IT MUST NEVER BE USED IN PRODUCTION BUILDS OR CI INTEGRATION RUNS.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_DIR="${ROOT_DIR}/Yoru/Frameworks/TDLibMock.xcframework"

echo "[*] Generating TDLibMock.xcframework (FOR OFFLINE COMPILE-ONLY TESTS ONLY)..."

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

cd "${TMP_DIR}"

cat << 'EOF' > td_json_client.h
#ifndef TD_JSON_CLIENT_H
#define TD_JSON_CLIENT_H
#ifdef __cplusplus
extern "C" {
#endif
void* td_json_client_create(void);
void td_json_client_send(void* client, const char* request);
const char* td_json_client_receive(void* client, double timeout);
const char* td_json_client_execute(void* client, const char* request);
void td_json_client_destroy(void* client);
#ifdef __cplusplus
}
#endif
#endif
EOF

cat << 'EOF' > td_log.h
#ifndef TD_LOG_H
#define TD_LOG_H
#ifdef __cplusplus
extern "C" {
#endif
void td_set_log_message_callback(int max_verbosity_level, void (*callback)(int verbosity_level, const char* message));
#ifdef __cplusplus
}
#endif
#endif
EOF

cat << 'EOF' > TDLibMock.h
#ifndef TDLibMock_h
#define TDLibMock_h
#include "td_json_client.h"
#include "td_log.h"
#endif
EOF

cat << 'EOF' > module.modulemap
module TDLibMock {
    umbrella header "TDLibMock.h"
    export *
    module * { export * }
}
EOF

cat << 'EOF' > td_mock.c
#include "td_json_client.h"
#include "td_log.h"
#include <stdlib.h>
void* td_json_client_create(void) { return malloc(sizeof(int)); }
void td_json_client_send(void* client, const char* request) { (void)client; (void)request; }
const char* td_json_client_receive(void* client, double timeout) { (void)client; (void)timeout; return NULL; }
const char* td_json_client_execute(void* client, const char* request) { (void)client; (void)request; return NULL; }
void td_json_client_destroy(void* client) { if (client) free(client); }
void td_set_log_message_callback(int v, void (*cb)(int, const char*)) { (void)v; (void)cb; }
EOF

SIM_SDK="$(xcrun --sdk iphonesimulator --show-sdk-path)"
DEV_SDK="$(xcrun --sdk iphoneos --show-sdk-path)"

mkdir -p sim_fw/TDLibMock.framework/Headers
mkdir -p sim_fw/TDLibMock.framework/Modules
cp td_json_client.h td_log.h TDLibMock.h sim_fw/TDLibMock.framework/Headers/
cp module.modulemap sim_fw/TDLibMock.framework/Modules/

mkdir -p dev_fw/TDLibMock.framework/Headers
mkdir -p dev_fw/TDLibMock.framework/Modules
cp td_json_client.h td_log.h TDLibMock.h dev_fw/TDLibMock.framework/Headers/
cp module.modulemap dev_fw/TDLibMock.framework/Modules/

xcrun clang -target arm64-apple-ios17.0-simulator -isysroot "${SIM_SDK}" -dynamiclib -install_name @rpath/TDLibMock.framework/TDLibMock -o sim_arm64.dylib td_mock.c
xcrun clang -target x86_64-apple-ios17.0-simulator -isysroot "${SIM_SDK}" -dynamiclib -install_name @rpath/TDLibMock.framework/TDLibMock -o sim_x86_64.dylib td_mock.c
lipo -create sim_arm64.dylib sim_x86_64.dylib -output sim_fw/TDLibMock.framework/TDLibMock

xcrun clang -target arm64-apple-ios17.0 -isysroot "${DEV_SDK}" -dynamiclib -install_name @rpath/TDLibMock.framework/TDLibMock -o dev_fw/TDLibMock.framework/TDLibMock td_mock.c

mkdir -p "${ROOT_DIR}/Yoru/Frameworks"
rm -rf "${OUTPUT_DIR}"

xcodebuild -create-xcframework \
    -framework sim_fw/TDLibMock.framework \
    -framework dev_fw/TDLibMock.framework \
    -output "${OUTPUT_DIR}"

echo "[+] Successfully created isolated TDLibMock.xcframework (FOR OFFLINE TESTING ONLY) at ${OUTPUT_DIR}"
