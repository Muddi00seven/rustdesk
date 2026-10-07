# Upstream audit

Audit date: 2026-10-07, Asia/Kolkata.

| Item | Recorded value |
| --- | --- |
| Fork | https://github.com/Muddi00seven/rustdesk |
| Parent | https://github.com/rustdesk/rustdesk |
| Branch | `macpilot/main` |
| Base SHA | `9f9585ce155a6558f0625eaf8fabfe8827c9a552` |
| Common submodule | `229b904508364c8997aad0fb5af57effac859f60` |
| License | GNU Affero General Public License v3, retained in `LICENCE` |
| Original workspace remote | `workspace-origin = https://github.com/Muddi00seven/iDesk.git` |

The existing workspace was an empty Git repository. A real GitHub fork was created using the account's existing Git authentication; its parent is `rustdesk/rustdesk`. The checkout now contains upstream history, `origin` points to the fork, and `upstream` is preserved. No credentials were recorded.

## Source inspected

The audit inspected `README.md`, `Cargo.toml`, `Cargo.lock`, `build.py`, `build.rs`, `.cargo/config.toml`, `.gitmodules`, `vcpkg.json`, `.github/workflows/flutter-build.yml`, `.github/workflows/bridge.yml`, `flutter/pubspec.yaml`, both Apple Podfiles and Xcode projects, iOS `AppDelegate.swift` and `Info.plist`, macOS `MainFlutterWindow.swift` and branding config, `docs/CONTRIBUTING.md`, and the current development build documentation.

Platform/session inspection included `src/platform/macos.rs`, `src/platform/macos.mm`, `src/client.rs`, `src/flutter_ffi.rs`, `src/server/clipboard_service.rs`, `libs/scrap/build.rs`, `flutter/lib/models/input_model.dart`, and `flutter/lib/mobile/pages/remote_page.dart`. This is the baseline audit; a complete feature-by-feature architecture trace is still required after baseline compilation.

## Exact CI toolchain

| Component | Apple CI value |
| --- | --- |
| Application Flutter | `3.24.5`, commit `dec2ee5c1f98f8e84a7d5380c05eb8a3d0a81668` |
| Bridge Flutter | `3.22.3`, commit `b0850beeb25f6d5b10426284f506557f66181b36` |
| macOS Rust | `1.81` (installed as `1.81.0`) |
| iOS and bridge Rust | `1.75` (installed as `1.75.0`) |
| Bridge generator | `1.80.1` |
| cargo-expand | `1.0.95` |
| vcpkg | `9e593bb18ea69cc5095e012465dcd675a822ed0d` (2026.07.29) |
| CI CMake environment | `4.3.0` |
| Pinned vcpkg macOS tool manifest CMake | `4.4.0` (actual minimum selected by vcpkg) |
| macOS NASM | `2.16.03`; CI explicitly warns against NASM 3.x |
| Apple Silicon macOS | `aarch64-apple-darwin`, `arm64-osx`, minimum macOS `12.3` |
| Physical iOS | `aarch64-apple-ios`, `arm64-ios` |

The manifest's declared Rust minimum (`1.75`) does not establish that every current dependency compiles with it. The build will use the CI versions first; actual compiler incompatibilities must be recorded and diagnosed instead of silently switching to another Rust version or rewriting the lockfile.

## Build observations

1. README's raw build instructions describe the deprecated Sciter UI and an old vcpkg release. Current Flutter CI is authoritative.
2. Default bridge generation runs on Linux with Flutter 3.22.3 and temporarily changes `extended_text` from 14.0.0 to 13.0.0; Apple application builds use Flutter 3.24.5. Local scripts reproduce that resolution change and restore the application pubspec.
3. Both Apple builds apply upstream's dropdown-menu patch to Flutter 3.24.5. macOS additionally comments out `_setFramesEnabledState(false)` in the SDK as CI does. Both SDKs are installed in a project-specific cache, not into an existing user SDK.
4. Apple Silicon CI adjusts four deployment-target declarations to 12.3 and runs `build.py --flutter --hwcodec --unix-file-copy-paste --screencapturekit`.
5. iOS builds the Rust static library with `cargo build --locked --features flutter,hwcodec --release --target aarch64-apple-ios --lib`, then `flutter build ipa --release --no-codesign`.
6. The iOS Xcode project links the static library directly from `target/aarch64-apple-ios/release/liblibrustdesk.a`. A simulator needs a different Rust target and library slice; substituting the physical-device archive is invalid.
7. Upstream contains an upstream developer team identifier. It must be replaced with the user's chosen team in the local build checkout before a signed device run; no Apple account has been changed.
8. macOS packages `service` with the app. This must be checked alongside the app executable. Packaging/notarization is separate from local baseline validation.
9. `libs/hbb_common` is a submodule; client-only protocol/config additions belong in `libs/base` where possible.

## Baseline result

At the initial audit full Xcode was absent and `xcode-select` pointed to `/Library/Developer/CommandLineTools`. Xcode 27.0 (27A266a) subsequently became available and selected at `/Applications/Xcode.app/Contents/Developer`; its first-launch/license setup cleared. The audit did not change the system developer-directory selection.

The unmodified macOS engine and service compiled with Rust 1.81.0, and Flutter 3.24.5 produced `RustDesk.app`. All three executables/libraries have native arm64 slices. Xcode 27 required forwarding upstream's existing macOS 12.3 minimum to generated Pods. The pinned Flutter release compiler required Rosetta, which Apple's installer installed without sudo. Upstream's post-build service copy invalidated the bundle seal; local ad-hoc signing restored it, and strict/deep signature verification passed. The app launched, rendered the upstream connection screen, and reported Ready. Screen Recording remains ungranted; no remote session is claimed.

The iOS library compiled with Rust 1.75.0 and Flutter produced an unsigned `Runner.xcarchive` (276 MB). Its Runner executable is native arm64; archive metadata confirms RustDesk branding and a 15.0 deployment target. The installed SDK rejects upstream's generated Pod target of 11.0; the script now derives and forwards the supported minimum from `SDKSettings.json`. Codesigning is disabled as in CI, so there is no installable signed IPA yet.

Both compilation gates and the runnable macOS launch check have passed. No connected iPad or valid Apple code-signing identity has been discovered yet; physical installation, baseline remote session and acceptance remain blocked. The user has offered to connect an iPad and has been asked to complete local signing setup. The baseline checkpoint is recorded in `BASELINE_RESULTS.md`; no product behavior changes are included.

Source: [pinned Apple CI](https://github.com/rustdesk/rustdesk/blob/9f9585ce155a6558f0625eaf8fabfe8827c9a552/.github/workflows/flutter-build.yml), [pinned bridge CI](https://github.com/rustdesk/rustdesk/blob/9f9585ce155a6558f0625eaf8fabfe8827c9a552/.github/workflows/bridge.yml), [upstream build documentation](https://rustdesk.com/docs/en/dev/build/).
