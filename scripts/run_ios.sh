#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/macpilot/common.sh"
[[ $# -ge 1 ]] || fail "Usage: scripts/run_ios.sh DEVICE_ID [--working-tree]. Discover IDs with scripts/doctor.sh --devices."
device_id="$1"
shift
source_mode=baseline
[[ "${1:-}" != --working-tree ]] || source_mode=working-tree
[[ $# -eq 0 || ( $# -eq 1 && "$1" == --working-tree ) ]] || fail "Usage: scripts/run_ios.sh DEVICE_ID [--working-tree]"
require_build_tools
export RUSTUP_TOOLCHAIN="$MACPILOT_IOS_RUST_VERSION"
if [[ "$source_mode" == baseline ]]; then
    MACPILOT_BUILD_ROOT="$MACPILOT_ROOT/target/macpilot-baseline/ios"
else
    MACPILOT_BUILD_ROOT="$MACPILOT_ROOT"
fi
[[ -s "$MACPILOT_BUILD_ROOT/target/aarch64-apple-ios/release/liblibrustdesk.a" ]] || fail "Build the iOS library with scripts/build_ios.sh first."
cd "$MACPILOT_BUILD_ROOT/flutter"
FLUTTER_XCODE_IPHONEOS_DEPLOYMENT_TARGET="$(supported_deployment_target iphoneos 13.0)"
export FLUTTER_XCODE_IPHONEOS_DEPLOYMENT_TARGET
flutter run --release -d "$device_id"
