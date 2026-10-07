# Milestone 2: physical deployment and remote-session validation

Status: in progress. A physical installation has succeeded; no authenticated remote session is claimed.

## Physical deployment evidence

On 2026-10-07 the connected device is an iPad16,8 running iPadOS 27.0.1, wired, paired, with Developer Mode enabled. The user signed into Xcode and explicitly authorized selecting their existing Personal Team through computer use. Xcode initially refused provisioning because upstream's controller declared Access Wi-Fi Information and Push Notifications, which this Personal Team does not support.

The controller AppDelegate, Flutter sources, registered plugin/dependency lists and Rust sources were searched for APNs registration and Wi-Fi-information APIs. No use was found. The two unused entitlement declarations were removed. Camera/photo QR descriptions and ordinary networking remain unchanged. The upstream baseline checkouts retain their original entitlements.

After selecting the physical iPad as the run destination, Xcode resolved a development certificate and managed profile. The selected team is stored in an ignored local xcconfig; shared project settings do not contain the user's team or retain upstream's unrelated team.

| Check | Observed result |
| --- | --- |
| Development signing identities | One valid identity after authorized Xcode signing setup |
| Profile coverage | Connected iPad included; development profile expires 2026-10-14 |
| Signed controller release build | Passed; Xcode 104.3 seconds, Runner.app 71.6 MB |
| Controller bundle metadata | MacPilot; `io.github.muddi00seven.macpilot.controller`; minimum iOS 15.0 |
| Local signing configuration | Debug, Release and Profile resolve the selected local team and controller identifier; local xcconfig is ignored by Git |
| Signature verification | `codesign --verify --deep --strict` passed |
| Physical app installation | `devicectl device install app` passed |
| Developer trust | Initial CoreDevice 10002 / FBS security rejection resolved after the user completed device trust |
| iPadOS 27 launch regression | Before the fix, accepted launch requests immediately ended in `EXC_BREAKPOINT` / `SIGTRAP`; the crashing UIKit frame was `___UIApplicationEvaluateRuntimeIssueForNoSceneLifecycleAdoption_block_invoke` |
| Scene lifecycle fix | Signed release rebuilt in 10.8 seconds, deep/strict signature and scene metadata verified, reinstalled; the original Runner process remained alive at 118 seconds after launch |
| Hardware dashboard | Device Hub showed the actual iPad dashboard and Add Mac form in portrait, then the dashboard in landscape |
| Cold-start URL route | `devicectl` terminated/relaunched the app with the existing `rustdesk://` connection route; the controller attempted the selected Mac and displayed the public server's login-required rejection |
| Warm URL/lifecycle | An existing-process payload request brought the dashboard forward but did not visibly open a connection; warm routing is not accepted. The original process survived the observed Home/foreground/rotation sequence with no new Runner crash files; session lifecycle remains pending |
| Mac permissions | User authorized Screen Recording and Accessibility and completed OS authentication; both actual product-app entries were enabled in System Settings, and the host was relaunched after Screen Recording. Capture/control behavior still needs a session |
| Authenticated session, capture and control | Pending |

No certificate/private-key material, passwords, tokens, clipboard contents or typed input are included in this report. Device identifiers and local signing configuration are excluded from Git.

## iPadOS 27 launch compatibility

The physical crash exposed a platform requirement that unsigned compilation did not test. [Apple's scene migration guide](https://developer.apple.com/documentation/uikit/transitioning-to-the-uikit-scene-based-life-cycle) and [Flutter's migration notice](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate) describe the scene lifecycle requirement for SDK 27. The pinned Flutter 3.24 framework has no `FlutterSceneDelegate`; upgrading the engine and dependencies would broaden this repair.

`MacPilotSceneDelegate` supplies a single UIKit scene using the existing Main storyboard's Flutter controller. It prepares that controller before plugin registration, attaches it to the scene window, and delivers legacy plugin launch callbacks with scene cold-start URL options. It forwards scene activation/background and URL/user-activity callbacks to the existing Flutter AppDelegate. The engine, storyboard and plugin registrant remain unchanged. Without a scene manifest, the AppDelegate's existing launch path still runs. Future Flutter migration should replace this compatibility adapter with the supported Flutter scene delegate after retesting these paths.

This checkpoint proves that the previously crashing binary launches, renders the dashboard and handles a cold-start connection URL on the tested device. It does not establish authentication, video frames, input, warm URL routing, older-iPadOS compatibility or long-session stability. No new test harness was introduced; the before/after physical launch check is the regression test for the observed UIKit crash.

## Current session blocker

The cold-start connection attempt returned the public server's login-required rejection before host authentication. [RustDesk's public-server guide](https://github.com/rustdesk/rustdesk/wiki/Login-required-for-public-server) confirms this requirement and that first third-party sign-in creates an account. No account was created or signed in by the agent. The user can complete controller sign-in, or supply an existing self-hosted server address and public key.

The existing Direct IP option is off and the default port is not listening. The pinned upstream direct-IP path returns a raw TCP stream without invoking its secure-connection handshake (`src/client.rs` IP/domain branches; direct server passes `secure = false`). This is not a suitable encrypted acceptance path without a separately established secure network. Direct IP was not enabled. No authentication/encryption check, firewall, server configuration or service was changed to bypass the public-server requirement.

Device Hub was useful for physical display verification. Coordinate actions returned `noWindowsAvailable`, so the agent could not complete the Add Mac form through mirrored taps. Its temporary Capture Keyboard option was off again after returning to the full Device Hub window. No remote desktop or typed password was captured as acceptance evidence.

## Remaining milestone gate

Resolve public-server sign-in or configure an authorized existing server, then demonstrate an authenticated iPad-to-Mac session with visible host-session indication and working capture/control. Exercise connect/disconnect, warm URL routing and foreground lifecycle; record transport and stability observations without inventing latency or frame metrics. Run the required Apple builds and relevant checks before marking this milestone complete.

## Regression surface

- `flutter/ios/Runner/Runner.entitlements`: removes two unused capability requests that blocked observed Personal Team provisioning. No transport, input, capture or authentication implementation changes.
- `flutter/ios/Runner.xcodeproj/project.pbxproj`: removes the three inherited development-team assignments so a local team resolves from xcconfig, and registers the new adapter in Runner's source phase so the declared scene class is bundled. No other phase or build setting changes.
- `flutter/ios/Runner/AppDelegate.swift`: thin scene preparation/launch hooks preserve plugin registration and the legacy path when no scene manifest is present. Deferring the scene launch callback supplies cold-start URLs to the existing plugin.
- `flutter/ios/Runner/Info.plist`: declares one scene and removes UIKit's automatic main-storyboard launch; the adapter explicitly loads the unchanged storyboard. This is necessary to avoid the observed SDK 27 launch trap.
- `flutter/ios/Runner/MacPilotSceneDelegate.swift`: new iOS-only compatibility code owns scene window and lifecycle forwarding; no shared Flutter or Rust runtime path changed.
- `flutter/ios/Flutter/Debug.xcconfig` and `Release.xcconfig`: optional local signing include, also covering Profile's existing Release include. A missing local file changes no unsigned-build behavior.
- `flutter/.gitignore`: excludes local signing-team configuration.
- Setup, test-plan and limitation documentation records actual deployment results and pending physical acceptance.

Xcode-only plist reordering and unrelated build-phase serialization were removed after verifying that they changed no semantic values. No submodule, dependency lock, protocol, service-installation or shared Rust path changes are part of this checkpoint.
