# Validation plan and actual results

## Results to date

| Check | Result |
| --- | --- |
| macOS environment and current upstream audit | Completed; see `ENVIRONMENT.md` / `UPSTREAM.md` |
| Fork and exact submodule | Verified |
| Pinned tool bootstrap | Completed and repeated successfully without forcing reinstalls |
| Shell syntax | All new shell scripts pass `/bin/bash -n` |
| CI build substitutions | Three Python regression tests pass, including repeatable deployment targets, refusal of an unknown bridge dependency pattern, and isolated native package/Rust roots |
| Cargo workspace manifests | All 10 packages parse with `cargo +1.81.0 metadata --locked --no-deps` |
| Main checkout runtime regression surface | Milestone 1: conditional Apple title/iOS home hooks, native metadata/icons and CI deployment targets; engine/session/input/authentication paths unchanged. See `MILESTONE_1.md` |
| macOS baseline compilation/run | Rust engine/service and Flutter release app compiled; native arm64 verified; deep/strict ad-hoc signature verified; launched and renders upstream connection page with Ready status. Remote session pending host permissions and physical iPad |
| iOS baseline compilation/run | Rust static library and unsigned Xcode release archive compiled; arm64 Runner and iOS 15.0 archive metadata verified. Physical installation/run pending signing and iPad connection |
| Physical iPad/signing | Wired iPad16,8 / iPadOS 27.0.1, Developer Mode and developer trust completed; profile includes the device, deep/strict signed release verification and installation passed. SDK 27's observed scene-lifecycle launch trap was repaired; the original Runner process stayed alive at 118 seconds. Device Hub showed portrait/landscape dashboard. After user account sign-in, a cold URL reached host authentication and the physical iPad rendered the Mac's controlled TextEdit fixture. Remote input, warm links and session lifecycle acceptance remain pending. See `MILESTONE_2.md` |
| Product host permissions | User authorized and enabled Screen Recording and Accessibility for the tested product path; host relaunched after Screen Recording. Capture and physical remote rendering verified; remote input remains pending |
| Scene-repair build checks | Full iOS Rust release and unsigned Xcode archive passed; Xcode 41.2 seconds, 276.3 MB, product identity verified. Full macOS Rust/Flutter release passed, 70.8 MB, deep/strict ad-hoc signature and product identity verified. Three script regression tests and six shell-script syntax checks pass. Physical relaunch/reconnect against the rebuilt host remains pending |
| Product feature tests | Six Flutter tests pass: profile round trip, persistence failure, invalid schema; empty state, correct Connect target/friendly name, 2× text/favorite action. Scoped MacPilot analyzer clean. Final product Apple release artifacts compiled; bundle names/identifiers and controller launch-art validation pass. Physical adapter/session flows remain pending |

Commands for current automated checks are in `DEVELOPMENT.md`. The baseline build scripts check native/app artifacts before reporting success. A successful prerequisites check or manifest parse is not compilation, a remote session, or MVP acceptance.

## Automated tests required as features are implemented

- Unit: connection stages, reconnect schedule/cap/cancellation, input gating and stale connection generations; editable/secure/multiline input context; one-shot and locked modifiers; device/settings serialization and storage failures; structured error mapping/redaction.
- Widget: device cards and available actions, connection stages, retained-frame reconnect overlay, toolbar inactivity/edge restoration, automatic/manual keyboard transitions, Settings → Controls and clipboard/server/privacy settings.
- Native: AX classification from role/subrole plus supported/settable attributes, denial and observer lifecycle; UIKit/Flutter input connection and hardware-keyboard attach/detach state. Fixtures must contain metadata, not actual field contents or passwords.
- Integration: real iPad-to-Mac transport, authenticated reconnect, capability/version fallback, focus detection, secure-field privacy, clipboard consent, monitor preference, host permissions, service lifecycle and revoked trust.

## MVP physical acceptance

### A — Touch only

Open the dashboard; connect to a saved Mac; navigate with direct touch; open Safari; tap its address bar; confirm the local keyboard appears; type a URL and Return; scroll; right-click by long press; change apps and type in an editor; disconnect. Verify manual Keyboard still works when an application does not expose useful AX metadata.

### B — Hardware keyboard and trackpad

Attach Magic Keyboard; connect; verify absolute pointer, hover, left/right/middle where exposed, drag, vertical/horizontal scrolling and typing. Exercise Cmd+C/V/A/Z, Cmd+Shift+Z, Cmd+S/F/L/T/W and available function/navigation keys. Document reserved/intercepted Cmd+Tab, Cmd+Space and Cmd+Q behavior on the tested iPadOS version. Confirm no unwanted software keyboard appears and test attach/detach during the session.

### C — Connection interruption

Disable the network for five seconds; confirm reconnect status, retained dimmed frame and disabled outbound input; restore the network; confirm safe authenticated recovery and no repeated keystrokes/buttons. Check retry timeout, Retry/Disconnect, background/foreground and lock/unlock. Never treat reconnect as permission to trust a changed server key.

### D — Host permissions

Remove Accessibility permission; confirm exact remediation and input-unavailable state. Repeat Screen Recording and required Input Monitoring denial, then restoration/relaunch. The session must not claim it is fully usable when capture/control is unavailable.

## Network and lifecycle matrix

Test Wi-Fi↔cellular; VPN on/off; loss and 500+ ms RTT; temporary DNS failure; relay and rendezvous outage; changed Mac IP; iPad lock/unlock and background/foreground; rotation, Split View and Stage Manager resize; sleeping display; Mac account switch and screen lock; remote app crash; host helper/service restart. Record device/OS versions, direct/relay transport, observed outcome, redacted error code, recovery time and input/frame behavior. Restore network and permissions after each controlled experiment.

## Performance and security acceptance

Measure input responsiveness, RTT, supported capture/encode/decode/render metrics, queues, bitrate and dropped frames. Mark unobservable metrics unavailable. Verify clipboard Ask/Off policy, no secret/plaintext diagnostics, no field text in input-context messages, server identity-change warning, brute-force controls, trusted-device revocation and visible host sessions. Confirm feature-off paths preserve upstream behavior.

## Milestone gate

After each implementation milestone: compile macOS and iOS, run tests relevant to the changed behavior, record actual results/limitations, inspect the regression surface and commit. The `macpilot-baseline` tag requires the successful unmodified baseline; MVP completion requires the real physical workflows above.
