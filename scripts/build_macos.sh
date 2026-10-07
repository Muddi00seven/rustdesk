#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/macpilot/common.sh"
source_mode=baseline
[[ "${1:-}" != --working-tree ]] || source_mode=working-tree
[[ $# -eq 0 || ( $# -eq 1 && "$1" == --working-tree ) ]] || fail "Usage: scripts/build_macos.sh [--working-tree]"
require_build_tools
export RUSTUP_TOOLCHAIN="$MACPILOT_MACOS_RUST_VERSION"
rustup run "$RUSTUP_TOOLCHAIN" rustc --version
prepare_source macos "$source_mode"
apply_apple_flutter_patches
if ! grep -F '//_setFramesEnabledState(false);' "$MACPILOT_FLUTTER_ROOT/packages/flutter/lib/src/scheduler/binding.dart" >/dev/null; then
    python3 "$MACPILOT_ROOT/scripts/macpilot/ci_adjustments.py" scheduler "$MACPILOT_FLUTTER_ROOT"
fi
build_bridge
cd "$MACPILOT_BUILD_ROOT"
case "$(uname -m)" in
    arm64)
        triplet=arm64-osx
        python3 "$MACPILOT_ROOT/scripts/macpilot/ci_adjustments.py" macos-arm64 "$MACPILOT_BUILD_ROOT"
        ;;
    x86_64) triplet=x64-osx ;;
    *) fail "Unsupported Mac architecture." ;;
esac
install_native_dependencies macos "$triplet"
if [[ "$triplet" == arm64-osx ]]; then
    # Xcode 27 rejects old deployment targets inherited by generated Pods.
    export FLUTTER_XCODE_MACOSX_DEPLOYMENT_TARGET=12.3
    python3 build.py --flutter --hwcodec --unix-file-copy-paste --screencapturekit
else
    python3 build.py --flutter --hwcodec --unix-file-copy-paste
fi
app="$MACPILOT_BUILD_ROOT/flutter/build/macos/Build/Products/Release/RustDesk.app"
[[ -x "$app/Contents/MacOS/RustDesk" && -x "$app/Contents/MacOS/service" ]] || fail "Build did not produce the macOS app and background service."
# Upstream copies the service after Xcode seals the application bundle.
codesign --force --sign - "$app/Contents/MacOS/service"
codesign --force --sign - --preserve-metadata=entitlements "$app"
codesign --verify --deep --strict "$app"
printf 'Built macOS app: %s\n' "$app"
