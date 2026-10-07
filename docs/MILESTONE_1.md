# Milestone 1: branding boundary and iPad dashboard

Implemented after the `macpilot-baseline` tag and baseline report. This is a development checkpoint, not MVP acceptance.

## Implemented behavior

- One canonical product configuration generates Flutter constants and Apple bundle metadata. Separate controller/host identifiers, neutral development icons and controller launch artwork are included.
- iOS opens My Macs with friendly names, Add Mac, rename/remove, favorites, Recent, Connect and Technical info. Empty state provides an actionable Add Mac button.
- Availability uses existing engine online/offline events; no response means unknown. Nearby means the peer is in the existing LAN discovery cache. Last seen is observed online in this dashboard process; last used records a connection attempt, not a successful authenticated handshake.
- Saved dashboard records contain only identifier, name, favorite and last-used timestamp. A failed bridge write future leaves the previous directory intact. Invalid stored data is preserved and reports a recovery path through Advanced. The inherited native option setter returns no disk-persistence result; native storage errors cannot be confirmed by this UI yet.
- Connect delegates to upstream `connect`. Settings and Advanced retain existing screens. Incoming-only builds and dashboard-disabled builds use the original home.
- Layout adapts to width, uses stock focus/semantics, and passes a 2× text-scale widget check. Current new copy is English; localization is a later hardening task.

## Verification

| Check | Result |
| --- | --- |
| Scoped Dart analysis | No findings in new MacPilot modules/tests |
| Flutter profile tests | 3 passed |
| Flutter dashboard tests | 3 passed |
| Dashboard visual inspection | Readable named cards/action controls verified at 1180×820; screenshot uses explicitly labeled test fixtures, not a live session |
| Development icons | Opaque 1024×1024 source, all configured iOS/macOS sizes and controller launch artwork generated |
| macOS product release | Rust engine/service and Flutter release passed. After correcting a remaining Release identifier override, packaging rebuilt with the compiled native artifacts. arm64 app/service, canonical bundle metadata and deep/strict signature verified; app launched and process remains running |
| iOS product release | Rust static library and final unsigned Flutter/Xcode release archive passed. arm64 Runner, controller identifier, display name and minimum 15.0 verified. App settings and launch-art validation pass |
| Physical iPad / session | Blocked: no connected iPad or valid signing identity in current inventory |

## Regression surface and minimization

Existing `flutter/lib/main.dart` changes are three imports and two conditional selection hooks: Apple Flutter title and iOS controller home. Dashboard-off runs the original HomePage; no existing input/session behavior is rerouted.

Apple xcconfig/Info.plist/project files consume the canonical display name and bundle identifier. Existing iOS icon/launch PNGs and macOS ICNS are replaced because the requested rebranding requires native artwork. Internal executable, service, protocol, URL-scheme and copyright names stay upstream's. Native identity/icons are not controlled by Dart feature flags. Actual bundle verification caught the final Release override before commit; all three macOS configurations now resolve to the host identifier.

`Cargo.toml`, `build.py`, macOS Podfile and project deployment settings move to 12.3, matching the pinned upstream Apple Silicon CI. This is required by the selected build configuration and already verified in the separate baseline. Flutter and both Pod lockfiles match the successful baseline resolutions; no product dependency was added. Existing preparation/build scripts generate branding and verify actual bundle identity only for `--working-tree`; baseline clones remain upstream application code. The existing upstream `docs/SECURITY.md` reporting policy is preserved, with a fork-specific development addendum.

No Rust production implementation, submodule revision, protocol, capture, encoder, input mapper, reconnect, authentication, clipboard or service installation path changes in this milestone. Advanced temporarily owns deep-link handling while its original connection page is open, avoiding duplicate connection launches.

## Next gate

Artifacts are `flutter/build/macos/Build/Products/Release/RustDesk.app` and `flutter/build/ios/archive/Runner.xcarchive`. Final macOS executable SHA256 is `370828fe26516375ec156ac0a07e4a77ed4a41d9110ac70db9413d24202f7234`; service is `77dc90bdb56aeace1c31540d16ab21c95eb5b814d0f304f204bd8aa8524fa39d`. The iOS archive has no bundle resource signature and cannot be installed as produced. The development Mac bundle is ad-hoc signed, not notarized.

Dashboard adapter lifecycle, Settings/Advanced navigation, deep links, restart persistence and Connect still need end-to-end device verification; widget tests exercise the presenter and profile boundary, not a live native session.

Milestone 2 requires a signed physical iPad installation, Mac capture/control permissions, and a demonstrated authenticated session. Pointer, hardware keyboard, automatic editable-focus keyboard, reconnect, trusted unattended access and physical acceptance A–D remain pending. See `ROADMAP.md` and `KNOWN_LIMITATIONS.md`.

## Existing-file inventory

| Existing files | Necessary change / runtime path |
| --- | --- |
| `flutter/lib/main.dart` | Conditional Apple application title and iOS controller home; original feature-off/unsupported home preserved |
| `flutter/ios/Flutter/Debug.xcconfig`, `flutter/ios/Flutter/Release.xcconfig`, `flutter/ios/Runner/Info.plist`, `flutter/ios/Runner.xcodeproj/project.pbxproj` | Generated product metadata includes and controller identifier in all configurations |
| `flutter/macos/Runner/Configs/AppInfo.xcconfig`, `flutter/macos/Runner/Info.plist`, `flutter/macos/Runner.xcodeproj/project.pbxproj` | Host display/identifier in all configurations; project also follows upstream CI minimum 12.3 |
| 15 existing PNGs in `flutter/ios/Runner/Assets.xcassets/AppIcon.appiconset`, 3 existing PNGs in `flutter/ios/Runner/Assets.xcassets/LaunchImage.imageset`, `flutter/macos/Runner/AppIcon.icns` | Native development icon/launch artwork |
| `Cargo.toml`, `build.py`, `flutter/macos/Podfile` | Upstream Apple Silicon CI deployment minimum 12.3; required for the selected native build |
| `flutter/pubspec.lock`, `flutter/ios/Podfile.lock`, `flutter/macos/Podfile.lock` | Match the dependency resolutions already compiled in the baseline; no product dependency added |
| `scripts/macpilot/common.sh`, `scripts/build_macos.sh`, `scripts/build_ios.sh` | Generate working-tree branding and check built product bundles; baseline-clone behavior preserved |
| `docs/SECURITY.md` | Append development threat/data boundary while retaining the original vulnerability-reporting policy |
| `README_MACPILOT.md`, `docs/ARCHITECTURE.md`, `docs/DEVELOPMENT.md`, `docs/ENVIRONMENT.md`, `docs/IOS_SETUP.md`, `docs/MACOS_SETUP.md`, `docs/ROADMAP.md`, `docs/TEST_PLAN.md` | Update actual implementation/build evidence and setup; no runtime behavior |
