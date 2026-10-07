# Reproducing the Apple baseline

## Prerequisites

Use a Mac with adequate disk space, full Xcode, Command Line Tools, Homebrew, Python 3, and rustup. Install Homebrew/rustup through their official installers if absent; the bootstrap deliberately does not execute unreviewed installer pipes or use sudo. Xcode comes from Apple's App Store or Developer Downloads. Launch it to complete installation and license review.

On Apple Silicon, install Rosetta through Apple's `softwareupdate --install-rosetta` and review its license prompt. The pinned Flutter release compiler is an Intel executable. Build preflight checks that Intel tools can run.

```sh
git clone --recurse-submodules https://github.com/Muddi00seven/rustdesk.git MacPilot
cd MacPilot
git fetch origin macpilot/main
git switch --track origin/macpilot/main
git remote add upstream https://github.com/rustdesk/rustdesk.git
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
scripts/bootstrap_macos.sh
scripts/doctor.sh --check
```

If preparing tools while Xcode is being installed, run `scripts/bootstrap_macos.sh --tools-only`, then run the full bootstrap after Xcode is ready. If the development branch has not been pushed yet, use the prepared local checkout instead of the branch-switch commands.

## Isolation and versions

Version pins are centralized in `scripts/macpilot/toolchain.env` and documented in `UPSTREAM.md`. Cache tools default to `~/Library/Caches/MacPilot/toolchains`; set `MACPILOT_CACHE_ROOT` to another writable directory if needed. CMake 4.4.0, required by the pinned vcpkg tool manifest, is installed in a dedicated Python virtual environment; CI's 4.3.0 environment value is retained separately in the pin record. NASM 2.16.03 is compiled natively into that cache to avoid requiring Rosetta or privileged copying. Homebrew installs Ninja, Yasm, LLVM, create-dmg, pkgconf, and CocoaPods when absent. Existing default Rust, shell configuration, Xcode settings, Keychain, certificates, and profiles are not replaced.

Bridge tools are compiled with Rust 1.75, as in upstream bridge CI. The tools-only bootstrap can use the installed Command Line Tools for dependency compilation if Xcode setup is incomplete; it changes only that process's `DEVELOPER_DIR`. The bridge Flutter SDK is 3.22.3; the application Flutter SDK is 3.24.5. Bootstrap disables Flutter/Dart analytics and vcpkg metrics. No MacPilot application analytics are added.

## Build and verify

```sh
scripts/build_macos.sh
scripts/build_ios.sh
```

These compile pinned upstream source in separate macOS/iOS clones under `target/macpilot-baseline/`. The macOS clone receives the exact Apple Silicon CI deployment-target adjustments. These are build configuration substitutions, not MacPilot product changes. Bridge generation applies the upstream dependency-resolution adjustment temporarily. Never replace a failed build's lockfile or disable checks to manufacture success.

With Xcode 27, the macOS script also forwards the existing Apple Silicon minimum target (12.3) to all generated Pod targets through Flutter's Xcode build-setting mechanism. This resolves SDK rejection of legacy Pod deployment targets.

The iOS script reads `SDKSettings.json` and forwards the larger of upstream's app minimum (13.0) and the installed SDK minimum. With Xcode 27 this is 15.0, replacing unsupported generated Pod targets of 11.0 without editing application code.

Native package installations are separate at `MACPILOT_CACHE_ROOT/native/macos/installed` and `native/ios/installed`. vcpkg manifest mode removes dependencies not required by the active manifest/triplet; sharing one installed database can remove the macOS FFmpeg package during an iOS install. Build-script `VCPKG_ROOT` is scoped to the selected package root because some upstream dependency build scripts hard-code its `installed` child. Run complete platform builds sequentially; their pinned vcpkg tool/source cache is shared.

When implementation has been authorized by a passing baseline, `scripts/build_macos.sh --working-tree` and `scripts/build_ios.sh --working-tree` build current development code. The macOS working-tree option applies CI deployment-target edits to that checkout, so review those expected differences afterward.

Check actual artifacts: the macOS app executable and service; the Rust iOS archive and Xcode app archive. An unsigned iOS archive cannot be installed on an iPad. See the platform setup guides for signing and running.

Both Rust/Flutter release builds have completed and the ad-hoc signed macOS app has launched. The iOS archive is unsigned. Scripts have also been exercised for syntax, CI substitutions, repeated tool installation, isolated native package roots, and missing-prerequisite failures. See `BASELINE_RESULTS.md`, `UPSTREAM.md` and `TEST_PLAN.md` for actual results; no physical session is accepted yet.

## Local verification

```sh
python3 -m unittest discover -s scripts/macpilot -p 'test_*.py'
bash -n scripts/bootstrap_macos.sh scripts/build_macos.sh scripts/build_ios.sh scripts/run_ios.sh scripts/doctor.sh scripts/macpilot/common.sh
scripts/doctor.sh --report docs/ENVIRONMENT.md
```

The baseline compilation/run checkpoint is tagged `macpilot-baseline`; physical installation and sessions remain pending. Use logical commits for each later milestone and repeat both Apple builds and relevant tests as requested. No Next.js build is part of this project.

## Product development

```sh
python3 scripts/macpilot/generate_branding.py
scripts/build_macos.sh --working-tree
scripts/build_ios.sh --working-tree
```

Run these sequentially. Product constants live in `macpilot/product.json`; generated files are committed so the Xcode projects remain inspectable. For a new development icon, supply an opaque 1024×1024 PNG at the configured `APP_ICON`, then run `python3 scripts/macpilot/generate_icons.py`. The included SVG is the editable source of the current neutral development mark. No support/privacy URL is fabricated; these values remain null until real pages exist.

With the cached application Flutter SDK:

```sh
MACPILOT_FLUTTER="$HOME/Library/Caches/MacPilot/toolchains/flutter-3.24.5/bin/flutter"
cd flutter
"$MACPILOT_FLUTTER" analyze lib/macpilot test/macpilot_device_profile_test.dart test/macpilot_dashboard_test.dart
"$MACPILOT_FLUTTER" test test/macpilot_device_profile_test.dart test/macpilot_dashboard_test.dart
```

Set `--dart-define=MACPILOT_DASHBOARD=false` when invoking Flutter directly to compare with the original mobile home. `MACPILOT_BRANDING=false` restores the original Flutter application title; native bundle identity/icons remain the configured product's. `SMART_REMOTE_KEYBOARD`, `NEW_IPAD_POINTER`, `NEW_RECONNECT_UI`, and `MAC_PERMISSION_ONBOARDING` default false. These pending features have no implementation yet, so enabling their declarations currently adds no behavior.
