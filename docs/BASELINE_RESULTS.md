# Upstream Apple baseline

Verified on 2026-10-07, Apple Silicon macOS 27.0.1 with Xcode 27.0 (27A266a).

- Source: `9f9585ce155a6558f0625eaf8fabfe8827c9a552` in both isolated build checkouts.
- Submodule: `229b904508364c8997aad0fb5af57effac859f60`.
- macOS: Rust 1.81.0, Flutter 3.24.5, upstream Flutter/hwcodec/unix-file-copy-paste/ScreenCaptureKit features. Native arm64 engine, service and app verified. Release Flutter app built (61.1 MB before the service copy), local ad-hoc seal verified with `codesign --verify --deep --strict`, launched and rendered upstream's connection screen with Ready status.
- iOS: Rust 1.75.0, Flutter 3.24.5, upstream Flutter/hwcodec features and `aarch64-apple-ios`. Rust static library and unsigned `Runner.xcarchive` built (276 MB). Runner is arm64; archive minimum iOS/iPadOS is 15.0. No signed IPA was produced.
- Bridge: Flutter 3.22.3, generator 1.80.1, cargo-expand 1.0.95; all six generated outputs verified.
- Native dependencies: pinned vcpkg and NASM 2.16.03, CMake 4.4.0; separate macOS/iOS package installation databases. See `UPSTREAM.md` for exact pins.
- Checks: three Python regression tests, shell syntax, diff whitespace, all ten Cargo manifests and exact source/submodule revisions passed.

## Build adaptations and evidence

Application source remains upstream's. The macOS clone contains CI's four deployment-target substitutions and resolved Pod/pub lockfiles. The iOS clone contains resolved Pod/pub lockfiles. Generated bridge/build outputs are ignored. Root source contains only additive setup scripts and documentation at this checkpoint.

Xcode 27 rejects legacy dependency targets. The macOS Xcode invocation forwards the existing 12.3 CI minimum; iOS forwards the maximum of upstream's 13.0 app minimum and the selected SDK minimum (15.0 here). Rosetta was installed from Apple because Flutter's pinned AOT compiler is Intel-hosted. The macOS service copy requires re-sealing the local app. These adaptations do not change application logic, credentials or Apple account settings.

The initial scripted builds exposed these failures; after diagnosis, the failing Flutter packaging stages were resumed using the already verified Rust artifacts. The reproduction scripts incorporate the corrections and check final artifacts. Successful manifest parsing or prerequisite checks are not substituted for native compilation.

Artifacts, relative to the workspace:

- `target/macpilot-baseline/macos/flutter/build/macos/Build/Products/Release/RustDesk.app`
- `target/macpilot-baseline/ios/flutter/build/ios/archive/Runner.xcarchive`

Executable SHA-256 fingerprints at this checkpoint:

- macOS RustDesk: `c2b1974c44ad6329bfcc1652215b4bc88f34cd8f560cce115c8707d15e56bf6d`
- iOS Runner: `41bc68cc575cec04732c382f1c58c359e5a4cd60996ee0caafcd0b515c2eded1`

## Physical checks still required

Xcode discovers this Mac and an offline iPhone; no physical iPad is connected. The signing inventory has zero valid Apple code-signing identities. The user has offered to connect an iPad and has been asked to configure signing in Xcode. The baseline Mac app reports missing Screen Recording permission. No service installation, login-item change, permission grant, iPad installation, remote session or physical acceptance A–D is claimed.

The baseline tag establishes compilation and the available launch check. It does not establish MVP completion or unattended-access reliability. Milestone 1 may now begin; physical session verification remains a gate for later input/reliability acceptance.
