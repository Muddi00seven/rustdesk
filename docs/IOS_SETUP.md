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

For the product build, use `scripts/build_ios.sh --working-tree`, then open `flutter/ios/Runner.xcworkspace`. The canonical development identifier is `io.github.muddi00seven.macpilot.controller`, generated from `macpilot/product.json`. The project still inherits upstream's development-team setting; select your existing team locally before physical deployment. If that team cannot provision this identifier, update the canonical identifier to one it owns and regenerate branding. Do not replace it with RustDesk's production identifier. Run with `scripts/run_ios.sh DEVICE_ID --working-tree`. No automatic Apple account, certificate or provisioning changes are performed by these scripts.

## Simulator limitations

The prepared build script targets physical iOS devices. The simulator requires `aarch64-apple-ios-sim` on Apple Silicon (or the correct Intel simulator target), matching native libraries, and adjusted Xcode linking. The physical-device Rust `.a` cannot be reused as a simulator slice. Simulator interaction does not establish hardware-keyboard, trackpad, privacy-prompt, network-transition, or accessibility-focus acceptance on an iPad.

## CocoaPods failures

Run Flutter dependency resolution before `pod install`; generated xcconfig files supply `FLUTTER_ROOT`. Use the `.xcworkspace`, not only the `.xcodeproj`. Verify CocoaPods and the selected Xcode before resolving pods. A pod deployment-target warning must be diagnosed from the actual error: upstream's iOS Podfile declares 13.0 but its post-install loop sets pod targets to 11.0. Do not delete signing state or reset the project to address a pod error. Keep the pinned Flutter version when diagnosing dependency resolution.

Source: [Flutter's iOS setup](https://docs.flutter.dev/platform-integration/ios/setup), plus the pinned upstream Podfile and CI documented in `UPSTREAM.md`.
