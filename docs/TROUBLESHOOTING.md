# Build troubleshooting

## Errors actually observed during baseline preparation

| Error | Cause | Resolution / current state |
| --- | --- | --- |
| `xcodebuild requires Xcode` | Only Command Line Tools were selected at the first audit | Full Xcode 27 subsequently became available |
| `You have not agreed to the Xcode license agreements` | Xcode first-launch/license setup was incomplete | Xcode was opened; SDK access subsequently cleared. Scripts now provide explicit setup remediation |
| NASM configure reports missing standard headers and `cannot make gcc report undeclared builtins` | Apple compiler began rejecting invocations during Xcode setup; this was not a NASM source bug | Tools-only bootstrap uses existing Command Line Tools through process-local `DEVELOPER_DIR` when full Xcode is not usable. NASM 2.16.03 then compiled successfully |
| Bridge generator panics with `only allow "debug" and "info"` | Installed generator 1.80.1 accepts only those two `RUST_LOG` values; the shell inherited `warn` | Set `RUST_LOG=info` for the generator invocation only; application logging policy is unchanged |
| vcpkg downloads CMake 4.4.0 despite CI's `VCPKG_CMAKE_VERSION=4.3.0` | Pinned vcpkg's own `scripts/vcpkg-tools.json` requires 4.4.0 on macOS | Allow its verified tool download. CI's environment value is not the complete tool requirement; record both values |
| iOS native install removes `ffmpeg:arm64-osx` | Both initial dependency jobs shared a manifest-mode installed database; the iOS dependency set does not require the macOS FFmpeg package | Build scripts now isolate each platform's installed database and scope Rust's package root accordingly; shared downloaded/build tool sources remain pinned |
| Xcode 27 rejects generated macOS Pods targeting 10.13/10.14 | The installed SDK supports deployment targets from macOS 12.0 | Forward `FLUTTER_XCODE_MACOSX_DEPLOYMENT_TARGET=12.3` to Xcode for all targets, matching upstream Apple Silicon CI. Application code and validation remain unchanged |
| Flutter cannot run `gen_snapshot_arm64`: incorrect architecture | Flutter 3.24.5 ships an Intel-hosted release compiler, even for arm64 output | Install Rosetta through Apple's `softwareupdate --install-rosetta`. The installer completed without sudo on this Mac; build preflight now verifies Intel tool execution |
| macOS signature verification reports `a sealed resource is missing or invalid` | Upstream copies its service into the app after Xcode has sealed it | Locally ad-hoc sign the service and re-seal the development app while retaining its entitlements, then verify. No certificate or Keychain entry is used; distribution signing/notarization remains separate |
| iOS archive fails Target Integrity for deployment target 11.0 | Upstream's post-install loop forces iOS 11, while Xcode 27's SDK requires 15.0 or later | Forward `FLUTTER_XCODE_IPHONEOS_DEPLOYMENT_TARGET` to every Xcode target, using the larger of upstream's app minimum (13.0) and the installed SDK minimum read from `SDKSettings.json`. On this Mac the local archive requires iOS/iPadOS 15.0 |

## Dependency resolution

The bridge uses Flutter 3.22.3 and temporarily resolves `extended_text` 13.0.0 as upstream CI does. Application resolution returns to Flutter 3.24.5 and `extended_text` 14.0.0. Different dependency selections during these two resolutions are expected. Keep application resolution and bridge resolution separate; do not update the main project's lockfiles just to suppress a warning.

First-time Flutter package resolution and Cargo metadata can download substantial dependency graphs and Git forks without regular console output. Check the owning build process and network/download progress before declaring a hang. Avoid simultaneous mutations of the same SDK, installed native package database or build checkout. `target/macpilot-baseline/` checkouts are disposable build artifacts, but the scripts do not delete or reset them automatically.

## Diagnostic hygiene

Use `scripts/doctor.sh --check` for prerequisites. Build logs may include source paths and public dependency names. Never export environment dumps, credential-helper output, signing material, typed input, screen contents or clipboard contents. Keep technical details separate from user-facing remediation. Session/network troubleshooting will be added only after actual runtime validation.
