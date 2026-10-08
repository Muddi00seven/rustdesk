# iPad keyboard and internet access changes

Implementation checkpoint, 2026-10-08. Updated app binaries have not been built or installed for this change; physical acceptance is pending.

## Behavior

- The Mac observes frontmost-application activation and Accessibility focused-element/window notifications. Only editable/secure booleans travel over the authenticated session. No AX value, field text, selection, application name or window title is read or transmitted. Read-only/unsupported controls fall back to the manual keyboard button.
- After the first remote image, an iOS controller with `SMART_REMOTE_KEYBOARD` enabled subscribes only when the Mac advertises the new capability. An editable focus event opens the hidden iPad text-input client; losing editable focus hides it. Existing input handling forwards text, Enter and Backspace. Focus changes reset local composition bookkeeping.
- Native iOS detection checks for an attached hardware keyboard before automatically showing software input. Manual Keyboard explicitly requests the keyboard even when the input client already has focus. Secure fields disable suggestions and personalized learning; the hidden client is obscured.
- iPad Mac sessions expose Esc and Tab in the normal accessory controls, with Command and Option labels. Existing modifier/key delivery is retained.
- My Macs now offers Edit Mac so a saved local address can be replaced with the Mac ID while retaining favorite/usage metadata. ID cards offer Connect via relay. More → ID / relay server opens the existing server configuration. Regular Connect retains the existing automatic transport selection.

Internet access uses the Mac ID, both apps on the same ID service, and an available direct or relay route. A saved private IP does not become globally routable. Keep the Mac awake and its app/service running. Public-service account requirements still apply. No router, firewall, authentication, transport-encryption or server credentials were changed.

## Verification

- Flutter: nine existing/new profile, dashboard and keyboard tests passed. Three added regressions cover keyboard opening/reopening and text delivery, relay actions without LAN discovery, and preserving preferences when replacing a local address with an ID.
- Scoped Dart analysis of MacPilot modules/tests: no findings. Analysis including shared remote/model files reports existing deprecation/style notices; no new errors or warnings.
- macOS Rust `cargo check --locked --release --features flutter,hwcodec,unix-file-copy-paste,screencapturekit --lib` passed with Rust 1.81.0.
- iOS Rust `cargo check --locked --release --features flutter,hwcodec --target aarch64-apple-ios --lib` passed with Rust 1.75.0.
- Native observer passed Clang syntax/warning checks. AppDelegate and the existing scene adapter passed Swift type checking against the installed iOS SDK and existing Flutter framework.
- Mac TCP probes reached the configured public ID endpoint (`rs-ny.rustdesk.com:21116`) and the relay endpoint previously assigned by that service (`ovh-po1.rustdesk.com:21117`). Probing port 21117 on the ID hostname was refused; the engine uses the separately assigned relay endpoint. These are reachability checks, not an authenticated cross-network session test.
- Final minimization preserves the original Android/non-Mac/feature-disabled text-input path, all existing transport selection, and the unchanged `hbb_common` submodule.

## Regression surface

Every changed existing runtime file is listed here. New implementation is isolated in `src/platform/macos_input_context.{mm,rs}` and `flutter/lib/macpilot/remote_keyboard.dart`.

| Existing file | Changed path and why necessary |
| --- | --- |
| `build.rs` | Compile the separate macOS Accessibility observer; original native compilation preserved |
| `src/platform/macos.rs` | Register the macOS-only observer module |
| `src/server/connection.rs` | Advertise capability, subscribe authorized remote-control sessions, filter queued metadata after input permission loss, and remove the observer on permission loss/unsubscribe/close |
| `libs/base/protos/message.proto` | Add optional client-owned Misc field 40 for focus metadata/subscription; older peers ignore it |
| `src/ui_session_interface.rs` | iOS-only option hook sends subscriptions through the existing bridge; iOS-only default UI callback delivers metadata without changing any existing signatures or requiring other callers to implement it |
| `src/client/io_loop.rs` | iOS Flutter-only dispatch of the new metadata message |
| `src/flutter.rs` | iOS-only focus event forwarding to Flutter |
| `flutter/ios/Runner/AppDelegate.swift` | Register native hardware-keyboard detection with the existing Flutter controller |
| `flutter/lib/models/model.dart` | Optional focus-event callback and keyboard-permission-loss notification; existing event paths preserved |
| `flutter/lib/mobile/pages/remote_page.dart` | Subscribe after the first image, open/hide the Mac-specific iOS input client, retain manual fallback and existing key delivery, expose Mac accessory actions; disabled/non-Mac sessions retain the original field |
| `flutter/lib/macpilot/features.dart` | Enable the requested keyboard behavior by default; `SMART_REMOTE_KEYBOARD=false` restores the original remote input UI |
| `flutter/lib/macpilot/device_profile.dart` | Permit an edited identifier while preserving profile metadata; distinguish direct-address cards and add a relay action |
| `flutter/lib/macpilot/dashboard.dart` | Expose relay on ID cards, show direct-address guidance, and expose Edit Mac |
| `flutter/lib/macpilot/home_page.dart` | Forward the relay choice to existing Connect, edit saved identifiers, and expose existing server settings |
| `flutter/test/macpilot_dashboard_test.dart`, `flutter/test/macpilot_device_profile_test.dart` | Add the two reported internet-access regressions; new keyboard regression is in `flutter/test/macpilot_remote_keyboard_test.dart` |
| `docs/KNOWN_LIMITATIONS.md`, `docs/ROADMAP.md` | Update implementation status without asserting physical acceptance |

## Physical checks still required

Install updated host/controller apps together. Confirm Mac Accessibility permission, then test TextEdit and browser inputs, field changes, secure input, Enter/Backspace, manual dismissal/reopening, and attached Magic/Bluetooth keyboard. Switch the iPad to a separate Wi-Fi network or cellular hotspot and connect using Mac ID; verify both automatic routing and Connect via relay. Observe connection statistics for the actual selected transport.

AX notifications and writability metadata vary by app. Unsupported controls need manual Keyboard. Hardware attach/detach during an active field, complex IMEs, foreground/reconnect transitions, and OS-reserved shortcuts still require device acceptance. Restoring input permission after revocation may require reconnecting to resume automatic focus notifications. No new reconnect, pointer or background-execution system is claimed.
