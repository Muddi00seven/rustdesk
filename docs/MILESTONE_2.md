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
| First launch | Rejected: CoreDevice 10002 / FBS security error 3; device developer trust still needs confirmation |
| Mac permissions | User authorized Screen Recording and Accessibility; macOS Touch ID confirmation pending |
| Authenticated session, capture and control | Pending |

No certificate/private-key material, passwords, tokens, clipboard contents or typed input are included in this report. Device identifiers and local signing configuration are excluded from Git.

## Remaining milestone gate

Verify device developer trust and actual launch, confirm the controller dashboard on hardware, grant/verify host capture and control permissions, then demonstrate an authenticated iPad-to-Mac session with visible host-session indication. Exercise connect/disconnect and foreground lifecycle; record transport and stability observations without inventing latency or frame metrics. Run the required Apple builds and relevant checks before marking this milestone complete.

## Regression surface

- `flutter/ios/Runner/Runner.entitlements`: removes two unused capability requests that blocked observed Personal Team provisioning. No transport, input, capture or authentication implementation changes.
- `flutter/ios/Runner.xcodeproj/project.pbxproj`: removes the three inherited development-team assignments so a local team can resolve from xcconfig instead of shipping another developer's account setting.
- `flutter/ios/Flutter/Debug.xcconfig` and `Release.xcconfig`: optional local signing include, also covering Profile's existing Release include. A missing local file changes no unsigned-build behavior.
- `flutter/.gitignore`: excludes local signing-team configuration.
- Setup, test-plan and limitation documentation records actual deployment results and pending physical acceptance.

Xcode-only plist reordering and unrelated build-phase serialization were removed after verifying that they changed no semantic values. No submodule, dependency lock, protocol, service-installation or shared Rust path changes are part of this checkpoint.
