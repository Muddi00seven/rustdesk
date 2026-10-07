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

Native package installations are separate at `MACPILOT_CACHE_ROOT/native/macos/installed` and `native/ios/installed`. vcpkg manifest mode removes dependencies not required by the active manifest/triplet; sharing one installed database can remove the macOS FFmpeg package during an iOS install. Build-script `VCPKG_ROOT` is scoped to the selected package root because some upstream dependency build scripts hard-code its `installed` child. Run complete platform builds sequentially; their pinned vcpkg tool/source cache is shared.

When implementation has been authorized by a passing baseline, `scripts/build_macos.sh --working-tree` and `scripts/build_ios.sh --working-tree` build current development code. The macOS working-tree option applies CI deployment-target edits to that checkout, so review those expected differences afterward.

Check actual artifacts: the macOS app executable and service; the Rust iOS archive and Xcode app archive. An unsigned iOS archive cannot be installed on an iPad. See the platform setup guides for signing and running.

The macOS Rust and Flutter release builds have completed and the ad-hoc signed app has launched. The iOS build is in progress. Scripts have also been exercised for syntax, CI substitutions, repeated tool installation, isolated native package roots, and missing-prerequisite failures. See `UPSTREAM.md` and `TEST_PLAN.md` for actual results; no physical session is accepted yet.

## Local verification

```sh
python3 -m unittest discover -s scripts/macpilot -p 'test_*.py'
bash -n scripts/bootstrap_macos.sh scripts/build_macos.sh scripts/build_ios.sh scripts/run_ios.sh scripts/doctor.sh scripts/macpilot/common.sh
scripts/doctor.sh --report docs/ENVIRONMENT.md
```

After both baseline builds succeed, run both apps, attempt a physical iPad-to-Mac session, record results, and create the `macpilot-baseline` commit/tag. A blocked prerequisite must not be labeled a successful baseline. Use logical commits for each later milestone and repeat both Apple builds and relevant tests as requested. No Next.js build is part of this project.
