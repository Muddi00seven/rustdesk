# macOS baseline setup

Install and launch full Xcode, set `DEVELOPER_DIR` to its developer directory, run the bootstrap, and check the doctor report. Apple Silicon builds follow upstream's minimum macOS 12.3 and ScreenCaptureKit feature configuration.

```sh
scripts/bootstrap_macos.sh
scripts/build_macos.sh
open target/macpilot-baseline/macos/flutter/build/macos/Build/Products/Release/RustDesk.app
```

The current Mac has Xcode 27 with SDK/compiler access working. Baseline compilation is in progress; the app has not yet been run.

## Permissions

Grant Screen Recording and Accessibility to the actual app path being tested in System Settings. Input Monitoring may also be requested by the current upstream input implementation; verify the actual host state rather than marking every permission ready automatically. Relaunch when macOS or upstream requires it after changes. Test permission removal and remediation before unattended access is accepted.

Permission grants do not establish an authenticated connection by themselves. Retain upstream authentication and visible host-session indicators. Do not log passwords, clipboard contents, keys, or keystrokes during debugging.

## Background service

Upstream macOS platform code manages LaunchDaemon/LaunchAgent plists and includes a separate `service` executable. Installing or replacing those services can invoke macOS authorization; it is separate from compiling and launching a local baseline. The audit has not installed a service or altered login items. Verify start-at-login, locked-screen behavior, reconnection, and trusted-device revocation on the actual target Mac before relying on unattended access.

## Signing

An unsigned/ad-hoc local build is for development. Gatekeeper, privacy permissions, and stable application identity can differ from a properly signed distribution build. Do not erase certificates or provisioning profiles or disable platform security to run the app. Distribution signing/notarization and future bundle IDs are separate later work. The bootstrap does not touch Apple signing material.
