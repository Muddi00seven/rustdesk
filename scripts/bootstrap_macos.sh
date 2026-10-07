#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/macpilot/common.sh"
tools_only=false
[[ "${1:-}" != --tools-only ]] || tools_only=true
[[ $# -eq 0 || ( $# -eq 1 && "$1" == --tools-only ) ]] || fail "Usage: scripts/bootstrap_macos.sh [--tools-only]"
[[ "$(uname -s)" == Darwin ]] || fail "This bootstrap is for macOS."
if [[ "$tools_only" == true && -z "${DEVELOPER_DIR:-}" ]] && ! xcrun --sdk macosx --show-sdk-path >/dev/null 2>&1; then
    if [[ -d /Library/Developer/CommandLineTools/SDKs ]]; then
        export DEVELOPER_DIR=/Library/Developer/CommandLineTools
        printf 'Using installed Command Line Tools for dependency setup in this shell only.\n'
    fi
fi
for name in git curl python3 rustup brew make clang; do require_command "$name"; done
mkdir -p "$MACPILOT_TOOLS_ROOT/bin" "$MACPILOT_TOOLS_ROOT/downloads"

missing_formulae=()
missing_count=0
for name in ninja yasm create-dmg pkg-config pod; do
    if ! command -v "$name" >/dev/null 2>&1; then
        formula="$name"
        case "$name" in pkg-config) formula=pkgconf ;; pod) formula=cocoapods ;; esac
        missing_formulae+=("$formula")
        missing_count=$((missing_count + 1))
    fi
done
llvm_prefix="$(brew --prefix llvm)"
if [[ ! -f "$llvm_prefix/lib/libclang.dylib" ]]; then
    missing_formulae+=(llvm)
    missing_count=$((missing_count + 1))
fi
if [[ $missing_count -gt 0 ]]; then
    HOMEBREW_NO_AUTO_UPDATE=1 brew install "${missing_formulae[@]}"
fi
rustup toolchain install "$MACPILOT_MACOS_RUST_VERSION" --profile minimal --component rustfmt
rustup toolchain install "$MACPILOT_IOS_RUST_VERSION" --profile minimal --component rustfmt --target aarch64-apple-ios

if [[ ! -x "$MACPILOT_TOOLS_ROOT/cmake/bin/cmake" ]] || ! "$MACPILOT_TOOLS_ROOT/cmake/bin/cmake" --version | head -1 | grep -F "$MACPILOT_CMAKE_VERSION" >/dev/null; then
    python3 -m venv "$MACPILOT_TOOLS_ROOT/cmake"
    "$MACPILOT_TOOLS_ROOT/cmake/bin/python" -m pip install --disable-pip-version-check "cmake==$MACPILOT_CMAKE_VERSION"
fi

install_flutter() {
    local version="$1" revision="$2" sdk="$MACPILOT_TOOLS_ROOT/flutter-$1"
    if [[ ! -d "$sdk" ]]; then
        git clone --depth 1 --branch "$version" https://github.com/flutter/flutter.git "$sdk"
    fi
    [[ -d "$sdk/.git" ]] || fail "Existing Flutter path is not a checkout: $sdk"
    [[ "$(git -C "$sdk" rev-parse HEAD)" == "$revision" ]] || fail "Existing Flutter checkout has a different revision: $sdk"
    "$sdk/bin/flutter" --disable-analytics
    "$sdk/bin/dart" --disable-analytics
    "$sdk/bin/flutter" --version
}
install_flutter "$MACPILOT_FLUTTER_VERSION" "$MACPILOT_FLUTTER_SHA"
install_flutter "$MACPILOT_BRIDGE_FLUTTER_VERSION" "$MACPILOT_BRIDGE_FLUTTER_SHA"
apply_apple_flutter_patches

if [[ ! -x "$MACPILOT_TOOLS_ROOT/nasm/bin/nasm" ]]; then
    archive="$MACPILOT_TOOLS_ROOT/downloads/nasm-$MACPILOT_NASM_VERSION.tar.xz"
    curl --fail --location --retry 3 --output "$archive" "https://www.nasm.us/pub/nasm/releasebuilds/$MACPILOT_NASM_VERSION/nasm-$MACPILOT_NASM_VERSION.tar.xz"
    tar -xf "$archive" -C "$MACPILOT_TOOLS_ROOT"
    (
        cd "$MACPILOT_TOOLS_ROOT/nasm-$MACPILOT_NASM_VERSION"
        ./configure --prefix="$MACPILOT_TOOLS_ROOT/nasm"
        make -j "$(sysctl -n hw.ncpu)"
        make install
    )
fi
nasm -v

if [[ ! -d "$VCPKG_ROOT" ]]; then
    git init --quiet "$VCPKG_ROOT"
    git -C "$VCPKG_ROOT" remote add origin https://github.com/microsoft/vcpkg.git
    git -C "$VCPKG_ROOT" fetch --depth 1 origin "$MACPILOT_VCPKG_SHA"
    git -C "$VCPKG_ROOT" checkout --quiet --detach "$MACPILOT_VCPKG_SHA"
fi
[[ "$(git -C "$VCPKG_ROOT" rev-parse HEAD)" == "$MACPILOT_VCPKG_SHA" ]] || fail "Refusing to alter an existing vcpkg checkout with a different revision."
if [[ ! -x "$VCPKG_ROOT/vcpkg" ]]; then
    "$VCPKG_ROOT/bootstrap-vcpkg.sh" -disableMetrics
fi
"$VCPKG_ROOT/vcpkg" version

export LIBCLANG_PATH="$llvm_prefix/lib"
cargo +"$MACPILOT_IOS_RUST_VERSION" install cargo-expand --version "$MACPILOT_CARGO_EXPAND_VERSION" --locked --root "$MACPILOT_TOOLS_ROOT"
cargo +"$MACPILOT_IOS_RUST_VERSION" install flutter_rust_bridge_codegen --version "$MACPILOT_CODEGEN_VERSION" --features uuid --locked --root "$MACPILOT_TOOLS_ROOT"
if [[ "$tools_only" == true ]]; then
    printf 'Toolchain setup complete. Full Xcode is still required for Apple builds.\n'
    exit 0
fi
require_build_tools
git -C "$MACPILOT_ROOT" submodule update --init --recursive
printf 'Bootstrap complete. Run scripts/doctor.sh --check, then the baseline build scripts.\n'
