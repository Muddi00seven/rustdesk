# Development environment

Audited: 2026-10-07T10:11:54+05:30 (Asia/Kolkata).

macOS 27.0.1 (26A434), arm64; 252.0 GiB free.

| Tool | Detected version |
| --- | --- |
| Xcode | Xcode 27.0; Build version 27A266a |
| Developer directory | /Applications/Xcode.app/Contents/Developer |
| Clang | Apple clang version 21.0.0 (clang-2100.3.34.2) |
| Homebrew | Homebrew 7.0.7 |
| Git | git version 2.54.0 |
| Rustup | rustup 1.29.1 (d95a37b6a 2026-08-13) |
| Rust | rustc 1.85.0 (4d91de4e4 2025-02-17) |
| Cargo | cargo 1.85.0 (d73d2caf9 2024-12-31) |
| Flutter | Flutter 3.24.5 • channel [user-branch] • unknown source |
| FVM | Not installed |
| CocoaPods | 1.16.2 |
| Python | Python 3.14.2 |
| CMake | cmake version 4.4.0 |
| Ninja | 1.13.2 |
| NASM | NASM version 2.16.03 compiled on Oct  7 2026 |
| Yasm | yasm 1.3.0 |
| pkg-config | 3.0.7 |
| Command Line Tools Clang | Apple clang version 21.0.0 (clang-2100.3.34.2) |
| vcpkg | vcpkg package management program version 2026-07-27-98d7cb0cf1f4686a3e43aa5672b6230c1d56bce8 |

## Installed Rust toolchains

- stable-aarch64-apple-darwin (active, default)
- nightly-aarch64-apple-darwin
- 1.75.0-aarch64-apple-darwin
- 1.79.0-aarch64-apple-darwin
- 1.81.0-aarch64-apple-darwin
- solana

## Apple device and signing status

Physical USB mobile-device labels: none discovered. This does not verify pairing, trust, or signing.

Use --devices with full Xcode.

Cached signing team names: none discovered.

Valid code-signing identities: 0; signing team IDs: none discovered. Only identity counts and team metadata are retained; no certificate material, private keys or Keychain secrets are read.

## Baseline prerequisite blockers


## Reproduction

Run `scripts/bootstrap_macos.sh --tools-only` for non-Xcode tools. Install and launch full Xcode, then run `scripts/bootstrap_macos.sh` and `scripts/doctor.sh --check`.

Run `scripts/doctor.sh --report docs/ENVIRONMENT.md` to refresh this report. This report contains only tool metadata; credentials, typed input, clipboard contents, and screen contents are never collected.
