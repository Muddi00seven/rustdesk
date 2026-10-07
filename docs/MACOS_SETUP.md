# macOS baseline setup

Install and launch full Xcode, set `DEVELOPER_DIR` to its developer directory, run the bootstrap, and check the doctor report. Apple Silicon builds follow upstream's minimum macOS 12.3 and ScreenCaptureKit feature configuration.

```sh
scripts/bootstrap_macos.sh
scripts/build_macos.sh
open target/macpilot-baseline/macos/flutter/build/macos/Build/Products/Release/RustDesk.app
```

The baseline has compiled and launched on this Apple Silicon Mac with Xcode 27. The window renders the upstream connection page and reports Ready. Screen Recording is not granted; a remote-control session has not yet been tested.

Build the product checkout with `scripts/build_macos.sh --working-tree`. Its native display name and icon are MacPilot and its development bundle identifier is `io.github.muddi00seven.macpilot.host`. The app artifact/executable remain `RustDesk.app`/`RustDesk` to preserve upstream service packaging. The macOS host connection UI remains upstream's; the new device dashboard is the iOS controller home. Internal configuration/service names are still shared with RustDesk. Do not install this development host alongside an active RustDesk service until milestone 7 isolates and verifies service identities.

## Permissions

Grant Screen Recording and Accessibility to the actual app path being tested in System Settings. Input Monitoring may also be requested by the current upstream input implementation; verify the actual host state rather than marking every permission ready automatically. Relaunch when macOS or upstream requires it after changes. Test permission removal and remediation before unattended access is accepted.

Permission grants do not establish an authenticated connection by themselves. Retain upstream authentication and visible host-session indicators. Do not log passwords, clipboard contents, keys, or keystrokes during debugging.

On 2026-10-07 the user authorized Screen Recording and Accessibility for the product host and completed OS authentication. Both entries were enabled for the actual development app path; the host was relaunched after Screen Recording. The macOS 27 Accessibility panel is presented as Device Control and Data Access. No Input Monitoring grant, service installation or login-item change was made. Actual capture and input still require the pending authenticated iPad session.

## Background service

Upstream macOS platform code manages LaunchDaemon/LaunchAgent plists and includes a separate `service` executable. Installing or replacing those services can invoke macOS authorization; it is separate from compiling and launching a local baseline. The audit has not installed a service or altered login items. Verify start-at-login, locked-screen behavior, reconnection, and trusted-device revocation on the actual target Mac before relying on unattended access.

## Signing

An unsigned/ad-hoc local build is for development. Gatekeeper, privacy permissions, and stable application identity can differ from a properly signed distribution build. Do not erase certificates or provisioning profiles or disable platform security to run the app. Distribution signing/notarization and future bundle IDs are separate later work. The bootstrap does not touch Apple signing material.

Upstream copies its service into the app after Xcode seals the bundle. The development build script ad-hoc signs that executable and re-seals the app while preserving its entitlements, then runs `codesign --verify --deep --strict`. This uses no certificate or private key and does not make the build notarized.
