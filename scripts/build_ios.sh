#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/macpilot/common.sh"
source_mode=baseline
[[ "${1:-}" != --working-tree ]] || source_mode=working-tree
[[ $# -eq 0 || ( $# -eq 1 && "$1" == --working-tree ) ]] || fail "Usage: scripts/build_ios.sh [--working-tree]"
require_build_tools
xcrun --sdk iphoneos --show-sdk-path >/dev/null 2>&1 || fail "Install the iOS platform SDK in Xcode."
export RUSTUP_TOOLCHAIN="$MACPILOT_IOS_RUST_VERSION"
rustup run "$RUSTUP_TOOLCHAIN" rustc --version
rustup target add --toolchain "$RUSTUP_TOOLCHAIN" aarch64-apple-ios
prepare_source ios "$source_mode"
apply_apple_flutter_patches
build_bridge
cd "$MACPILOT_BUILD_ROOT"
install_native_dependencies ios arm64-ios
cargo build --locked --features flutter,hwcodec --release --target aarch64-apple-ios --lib
[[ -s target/aarch64-apple-ios/release/liblibrustdesk.a ]] || fail "The Rust iOS static library is missing."
cd flutter
flutter build ipa --release --no-codesign
archive="$MACPILOT_BUILD_ROOT/flutter/build/ios/archive/Runner.xcarchive"
[[ -d "$archive" ]] || fail "Build did not produce the iOS archive."
printf 'Built unsigned iOS archive: %s\nSigning is required before installation on an iPad.\n' "$archive"
