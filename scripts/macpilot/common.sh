#!/usr/bin/env bash
set -euo pipefail

MACPILOT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$MACPILOT_ROOT/scripts/macpilot/toolchain.env"
MACPILOT_CACHE_ROOT="${MACPILOT_CACHE_ROOT:-$HOME/Library/Caches/MacPilot}"
MACPILOT_TOOLS_ROOT="$MACPILOT_CACHE_ROOT/toolchains"
MACPILOT_FLUTTER_ROOT="$MACPILOT_TOOLS_ROOT/flutter-$MACPILOT_FLUTTER_VERSION"
MACPILOT_BRIDGE_FLUTTER_ROOT="$MACPILOT_TOOLS_ROOT/flutter-$MACPILOT_BRIDGE_FLUTTER_VERSION"
export VCPKG_ROOT="$MACPILOT_TOOLS_ROOT/vcpkg-$MACPILOT_VCPKG_SHA"
export PATH="$MACPILOT_TOOLS_ROOT/bin:$MACPILOT_TOOLS_ROOT/cmake/bin:$MACPILOT_TOOLS_ROOT/nasm/bin:$MACPILOT_FLUTTER_ROOT/bin:$PATH"
export COCOAPODS_DISABLE_STATS=true
export FLUTTER_SUPPRESS_ANALYTICS=true
export DART_SUPPRESS_ANALYTICS=true
export VCPKG_DISABLE_METRICS=1

fail() { printf 'MacPilot: %s\n' "$*" >&2; exit 1; }
require_command() { command -v "$1" >/dev/null 2>&1 || fail "Missing $1. Run scripts/bootstrap_macos.sh --tools-only."; }

require_xcode() {
    [[ "$(uname -s)" == Darwin ]] || fail "Apple builds require macOS."
    require_command xcodebuild
    xcodebuild -version >/dev/null 2>&1 || fail "Full Xcode is required; only Command Line Tools are active. Install and launch Xcode, then set DEVELOPER_DIR to its Contents/Developer directory. See docs/IOS_SETUP.md."
    xcrun --sdk macosx --show-sdk-path >/dev/null 2>&1 || fail "The macOS SDK is unavailable. Complete Xcode's license/first-launch setup and install platform support. See docs/IOS_SETUP.md."
}

require_build_tools() {
    require_xcode
    local name
    for name in git python3 rustup cargo flutter pod cmake ninja nasm yasm pkg-config; do
        require_command "$name"
    done
    [[ -x "$VCPKG_ROOT/vcpkg" ]] || fail "Pinned vcpkg is missing. Run scripts/bootstrap_macos.sh --tools-only."
    [[ "$(git -C "$MACPILOT_FLUTTER_ROOT" rev-parse HEAD)" == "$MACPILOT_FLUTTER_SHA" ]] || fail "Flutter checkout differs from the pinned Apple CI version."
    [[ "$(git -C "$VCPKG_ROOT" rev-parse HEAD)" == "$MACPILOT_VCPKG_SHA" ]] || fail "vcpkg checkout differs from the upstream manifest baseline."
    nasm -v | grep -F "$MACPILOT_NASM_VERSION" >/dev/null || fail "NASM 2.16.03 is required; upstream warns against NASM 3.x."
    cmake --version | head -1 | grep -F "$MACPILOT_CMAKE_VERSION" >/dev/null || fail "The pinned vcpkg baseline requires CMake 4.3.0."
    if command -v brew >/dev/null 2>&1; then
        local llvm_prefix
        llvm_prefix="$(brew --prefix llvm)"
        [[ -f "$llvm_prefix/lib/libclang.dylib" ]] || fail "Homebrew LLVM/libclang is missing."
        export LIBCLANG_PATH="$llvm_prefix/lib"
    else
        [[ -n "${LIBCLANG_PATH:-}" ]] || fail "Set LIBCLANG_PATH to an installed libclang directory."
    fi
}

prepare_source() {
    local platform="$1" source_mode="$2"
    MACPILOT_BUILD_ROOT="$MACPILOT_ROOT/target/macpilot-$source_mode/$platform"
    if [[ "$source_mode" == baseline ]]; then
        if [[ ! -d "$MACPILOT_BUILD_ROOT" ]]; then
            mkdir -p "$(dirname "$MACPILOT_BUILD_ROOT")"
            git clone --quiet --no-hardlinks --no-checkout "$MACPILOT_ROOT" "$MACPILOT_BUILD_ROOT"
            git -C "$MACPILOT_BUILD_ROOT" checkout --quiet --detach "$MACPILOT_UPSTREAM_SHA"
        fi
        [[ "$(git -C "$MACPILOT_BUILD_ROOT" rev-parse HEAD)" == "$MACPILOT_UPSTREAM_SHA" ]] || fail "Existing baseline checkout has a different commit. Review or rename it; this script will not overwrite it."
        git -C "$MACPILOT_BUILD_ROOT" submodule update --init --recursive --reference "$MACPILOT_ROOT/libs/hbb_common"
    else
        MACPILOT_BUILD_ROOT="$MACPILOT_ROOT"
        git -C "$MACPILOT_ROOT" submodule update --init --recursive
    fi
    export MACPILOT_BUILD_ROOT
}

apply_apple_flutter_patches() {
    local patch_file="$MACPILOT_ROOT/.github/patches/flutter_3.24.4_dropdown_menu_enableFilter.diff"
    if git -C "$MACPILOT_FLUTTER_ROOT" apply --reverse --check "$patch_file" >/dev/null 2>&1; then
        return
    fi
    git -C "$MACPILOT_FLUTTER_ROOT" apply --check "$patch_file" || fail "Upstream Flutter patch does not apply to the pinned SDK."
    git -C "$MACPILOT_FLUTTER_ROOT" apply "$patch_file"
}

build_bridge() {
    [[ -x "$MACPILOT_TOOLS_ROOT/bin/flutter_rust_bridge_codegen" ]] || fail "Bridge generator is missing. Run scripts/bootstrap_macos.sh."
    [[ -x "$MACPILOT_BRIDGE_FLUTTER_ROOT/bin/flutter" ]] || fail "Flutter 3.22.3 bridge SDK is missing. Run scripts/bootstrap_macos.sh --tools-only."
    local bridge_dir="$MACPILOT_BUILD_ROOT/flutter" saved_pubspec
    saved_pubspec="$(mktemp "${TMPDIR:-/tmp}/macpilot-pubspec.XXXXXX")"
    cp "$bridge_dir/pubspec.yaml" "$saved_pubspec"
    (
        trap 'cp "$saved_pubspec" "$bridge_dir/pubspec.yaml"; rm -f "$saved_pubspec"' EXIT
        export PATH="$MACPILOT_BRIDGE_FLUTTER_ROOT/bin:$PATH"
        # CI generates the Apple bridge with 3.22.3 and this one resolution change.
        python3 "$MACPILOT_ROOT/scripts/macpilot/ci_adjustments.py" bridge "$MACPILOT_BUILD_ROOT"
        cd "$bridge_dir"
        flutter pub get
        cd "$MACPILOT_BUILD_ROOT"
        flutter_rust_bridge_codegen --rust-input ./src/flutter_ffi.rs --dart-output ./flutter/lib/generated_bridge.dart --c-output ./flutter/macos/Runner/bridge_generated.h
        cp flutter/macos/Runner/bridge_generated.h flutter/ios/Runner/bridge_generated.h
    )
    (cd "$bridge_dir" && flutter pub get)
    local generated
    for generated in src/bridge_generated.rs src/bridge_generated.io.rs flutter/lib/generated_bridge.dart flutter/lib/generated_bridge.freezed.dart flutter/macos/Runner/bridge_generated.h flutter/ios/Runner/bridge_generated.h; do
        [[ -s "$MACPILOT_BUILD_ROOT/$generated" ]] || fail "Bridge generation did not produce $generated."
    done
}
