# Known limitations

Current checkpoint implements branding architecture and the iOS device dashboard. The requested production remote-work experience is not complete.

- Both upstream Apple baselines compiled. A signed product release has now installed on a paired physical iPad with Developer Mode enabled. Launch is pending developer-profile trust after an iPad security rejection; an authenticated session and host capture/control permission checks remain pending. See `MILESTONE_2.md`.
- Dashboard last used means a connection attempt. Last seen is an online response observed during the current process. A cached LAN discovery record is not proof of current reachability. Availability queries cover at most 20 distinct Macs; others remain unknown. There is no wake, thumbnail or latency claim on cards.
- Dashboard metadata uses upstream local Flutter options. Its native setter reports no disk-write result; the UI handles bridge failures but cannot confirm native persistence errors. Verify restart persistence on the physical controller before accepting per-device settings. No authentication secret is stored through this path.
- No automatic remote editable-field detection, new iPad pointer path, new hardware-keyboard mapping, reconnect overlay/state machine, MacPilot trust/revocation flow or permission onboarding is implemented. Their feature flags remain off.
- Native display names and launch icons are MacPilot. Internal engine configuration/service names, executable/artifact names, upstream host/Advanced text and deep-link scheme remain RustDesk. Full host branding/service isolation needs a later audited milestone. Do not install beside an active RustDesk service yet.
- Support/privacy URLs are unset. New dashboard copy is currently English. The development icon/name are provisional; no trademark clearance is claimed.
- The local macOS artifact is ad-hoc signed and not notarized; the milestone 1 iOS archive is unsigned. A separate signed development controller passed signature verification and installed on the iPad; its observed provisioning profile expires on 2026-10-14. Signing team configuration stays in an ignored local xcconfig. Xcode 27 local builds require macOS 12.3 / iOS 15.0 minimums. Only Apple Silicon was built here.
- The iOS simulator cannot use the physical-device Rust archive and does not establish trackpad, hardware-keyboard, TCC, network or remote-focus acceptance.
- iPadOS may reserve shortcuts and suspend apps in the background; continuous background control and interception of every Command shortcut are unproven. Use manual session controls and reconnect after foregrounding until validated.
- Secure fields and apps with incomplete AX metadata require manual keyboard fallback. No claim of automatic secure-field support is made.
- Wake from sleep, remote Internet wake, closed-lid MacBook operation, pre-login service operation and recovery after account switch depend on hardware/OS/network conditions and require separate physical testing.
- Clipboard consent/defaults, audio, monitor restoration, rotation/Split View/Stage Manager resizing, long sessions, and packet-loss recovery have not been accepted on a real iPad. Upstream support alone is not MacPilot acceptance.
- No self-hosted server has been provisioned and no relay/wrong-key/outage tests have run. App Store readiness is incomplete; nothing has been submitted.

Update this file from measured results after each milestone. Keep planned behavior in `ROADMAP.md`, and record evidence in `TEST_PLAN.md` and milestone reports.
