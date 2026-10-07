# iPad development setup

## Xcode and SDK

Install full Xcode from Apple and launch it to finish setup. Select/download iOS platform support in Xcode. Set `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` in the build shell to use that installation without changing the system's developer-directory setting. Verify `xcodebuild -version` and `xcrun --sdk iphoneos --show-sdk-path`.

If Xcode first-launch setup or license acceptance requires administrator access, complete it through Xcode's own setup UI. The project scripts do not accept Apple agreements or change your developer account.

## Baseline build

Run `scripts/bootstrap_macos.sh`, `scripts/doctor.sh --check`, and `scripts/build_ios.sh`. Upstream's physical-device target is `aarch64-apple-ios`; the resulting archive is unsigned. It does not establish device deployment readiness.

The scripts read the selected SDK's deployment minimum and forward the larger of that value and upstream's app minimum (13.0) to all Xcode targets. Xcode 27 requires 15.0, so this local archive requires iOS/iPadOS 15 or later. This is a build configuration adjustment; the baseline application source and behavior remain upstream's.

## Signing and physical iPad

1. Connect and unlock the iPad; accept the device's Trust prompt.
2. Enable Developer Mode if the device requires it. Finish any required restart and confirmation on the device.
3. Open `target/macpilot-baseline/ios/flutter/ios/Runner.xcworkspace` in Xcode after dependency resolution/build setup has generated it.
4. Select Runner's Signing & Capabilities, choose your existing development team, and choose a unique development bundle ID owned by that team. Upstream's `com.carriez.flutterHbb` and developer team do not belong to this project. These edits belong in the local baseline build checkout; retain the upstream source when validating the baseline.
5. Select the physical iPad and run from Xcode, or use `scripts/doctor.sh --devices` to discover the ID and `scripts/run_ios.sh DEVICE_ID` to run the signed release build.

No team, signing identity, or provisioning profile was created or changed during the audit. No cached signing teams were discovered. Signing setup requires the user's available Apple team/account and device trust.

For the product build, use `scripts/build_ios.sh --working-tree`, then open `flutter/ios/Runner.xcworkspace`. The canonical development identifier is `io.github.muddi00seven.macpilot.controller`, generated from `macpilot/product.json`. The shared project has no development-team assignment. Set `DEVELOPMENT_TEAM = YOUR_EXISTING_TEAM_ID` in `flutter/ios/Flutter/MacPilot.local.xcconfig`, which is excluded from Git and included by Debug, Release and Profile. Xcode's team picker can also set a team, but its project-file change is local signing configuration and should not be committed. If your team cannot provision this identifier, update the canonical identifier to one it owns and regenerate branding. Do not replace it with RustDesk's production identifier. Run with `scripts/run_ios.sh DEVICE_ID --working-tree`. These scripts do not configure an Apple account or explicitly create certificates/profiles; Xcode automatic signing may create or update signing assets after the user selects their team and device.

The product controller does not request Push Notifications or Access Wi-Fi Information. The pinned upstream controller declared those entitlements, but the audited app, Rust sources and registered plugins have no APNs registration or Wi-Fi-information API use. Xcode refused a Personal Team profile with these capabilities. Removing the unused declarations allows a development profile without disabling ordinary networking or changing the remote-session protocol. Baseline checkouts retain the upstream entitlements.

## Physical-device signing checkpoint, 2026-10-07

A wired, paired iPad (`iPad16,8`, iPadOS 27.0.1) has Developer Mode enabled. After the user authorized Personal Team selection, Xcode created a development identity and a profile covering that iPad. The signed release controller built (71.6 MB), passed deep/strict signature verification, and installed through `devicectl`. The observed profile expires on 2026-10-14; rebuild/reinstall with a valid profile before using it after expiration.

Initial launch was rejected with CoreDevice error 10002 / FBS security error 3. The user completed developer trust, after which launch requests were accepted. For that rejection, check Settings → General → VPN & Device Management → Developer App, select your own development account and use Trust/Verify if offered. Keep the device online for verification and follow its actual prompts. Apple documents the [developer trust flow](https://help.apple.com/xcode/mac/current/en.lproj/dev96a12fb84.html) and [device signing workflow](https://help.apple.com/xcode/mac/current/en.lproj/dev60b6fbbc7.html).

Accepted requests then exposed an immediate UIKit scene-lifecycle crash on iPadOS 27. The product now declares a single scene with an adapter for the pinned Flutter 3.24 AppDelegate. The repaired signed release compiled, reinstalled and remained running at the 118-second process check. Device Hub showed its portrait/landscape dashboard; a cold connection URL routed to the public server's login-required rejection. Complete controller Settings → Account → Login using your own account, or configure an authorized existing self-hosted server. First public-server sign-in creates an account according to [RustDesk's guide](https://github.com/rustdesk/rustdesk/wiki/Login-required-for-public-server). Warm URL/session lifecycle and authenticated session acceptance remain pending. See `MILESTONE_2.md`; installation or launch-request success alone is not acceptance.

## Simulator limitations

The prepared build script targets physical iOS devices. The simulator requires `aarch64-apple-ios-sim` on Apple Silicon (or the correct Intel simulator target), matching native libraries, and adjusted Xcode linking. The physical-device Rust `.a` cannot be reused as a simulator slice. Simulator interaction does not establish hardware-keyboard, trackpad, privacy-prompt, network-transition, or accessibility-focus acceptance on an iPad.

## CocoaPods failures

Run Flutter dependency resolution before `pod install`; generated xcconfig files supply `FLUTTER_ROOT`. Use the `.xcworkspace`, not only the `.xcodeproj`. Verify CocoaPods and the selected Xcode before resolving pods. A pod deployment-target warning must be diagnosed from the actual error: upstream's iOS Podfile declares 13.0 but its post-install loop sets pod targets to 11.0. Do not delete signing state or reset the project to address a pod error. Keep the pinned Flutter version when diagnosing dependency resolution.

Source: [Flutter's iOS setup](https://docs.flutter.dev/platform-integration/ios/setup), plus the pinned upstream Podfile and CI documented in `UPSTREAM.md`.
