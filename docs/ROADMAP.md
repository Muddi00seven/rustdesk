# MacPilot milestone status

The complete requested scope is retained in `MACPILOT_REQUIREMENTS.md`. This status reflects demonstrated behavior, not planned functionality.

| Milestone | Work | Status / acceptance gate |
| --- | --- | --- |
| 0 | Audit, fork, pinned tools, unmodified Apple builds, baseline run | Compilation gate passed for both Apple clients; macOS launched. Physical installation/session checks blocked by device/signing/host permissions. See `BASELINE_RESULTS.md` |
| 1 | Central branding and clean device dashboard | Implemented; six Flutter tests and scoped analysis pass. macOS release compiled/launched; final unsigned iOS archive compiled. Actual bundle identity and launch-art validation pass. See `MILESTONE_1.md` |
| 2 | Stable iPad-to-Mac session | In progress: signed physical deployment, SDK 27 launch repair, dashboard and cold connection route verified. Public-server sign-in or an authorized existing server is needed before authenticated session validation; see `MILESTONE_2.md` |
| 3 | Touch/direct/relative pointer, mouse identity, scroll | Pending baseline and existing-input trace |
| 4 | Hardware keyboard and touch modifier/accessory behavior | Pending physical keyboard tests |
| 5 | Event-based AX editable context and iPad text-input bridge | Pending SDK validation, privacy review, native and physical tests |
| 6 | Reconnect state machine and network quality | Pending authenticated-session lifecycle trace and fault-injection tests |
| 7 | Unattended access and permission onboarding | Pending service, secret-storage, revocation, and permission checks |
| 8 | Multiple Macs and per-device preferences | Pending secure persistence and dashboard integration |
| 9 | Self-hosting | Pending configured rendezvous/relay integration validation |
| 10 | Production hardening, documentation, diagnostics and acceptance | Pending all preceding milestones and physical acceptance A–D |

After each milestone: build both Apple clients, run relevant tests, document actual results and limitations, and create a logical Git checkpoint. `macpilot-baseline` records the completed compilation gate. Features remain isolated and preserve the upstream path when disabled. Milestone 2 requires a signed installation and a real iPad-to-Mac session before advancing the input milestones.

## Initial feasibility assessment

This is a planning classification, not an implementation claim. SDK and physical-device investigation may change it.

| Scope | Class | Fallback / validation |
| --- | --- | --- |
| Dashboard, neutral UI, onboarding, per-Mac preferences, settings, flags | A: straightforward | Reuse Flutter models, widgets and existing session entry points |
| Touch/relative trackpad mapping, haptics, pointer identity, resizing | B: platform constrained | Extend upstream input mapping; verify on physical iPad and hardware |
| Hardware keyboard and IME/emoji | B: platform constrained | Existing key/text paths; document OS interception and composition limits |
| Automatic AX editable focus and secure context | C: experimental | AXObserver metadata only; manual Keyboard always available |
| Forwarding iPadOS-reserved shortcuts reliably | D: not reliably possible | In-app shortcut/accessory actions where feasible |
| Text/URL/rich/image clipboard | B: platform constrained | Explicit Ask default; preserve supported upstream formats only |
| Resolution/scaling/FPS/codec and multi-monitor | B: platform constrained | Existing capability checks and per-host preference; avoid unsupported presets |
| Adaptive quality using complete loss/decode/render metrics | C: experimental | Start from available metrics and hysteresis; do not invent missing observations |
| Automatic reconnect with safe authenticated resume | B: platform constrained | Existing reconnect/authentication; input gate and no replay |
| Unattended host, Keychain trust, permission remediation | B: platform constrained | Existing service and macOS security boundary; real revocation tests |
| Wake sleeping Macs | B: platform constrained | LAN wake where supported; explicit always-on relay/VPN requirements |
| Control fully powered-off Macs without supported hardware | D: not reliably possible | Show Offline; no simulated wake action |
| LAN/direct/relay selection and self-hosted server settings | A: straightforward | Reuse upstream transport and server configuration |
| Structured errors, local diagnostics, redacted export and threat model | A: straightforward | Extend real events; omit unobservable metrics and sensitive content |
| Apple Pencil, external displays, OS attach/detach behavior | B: platform constrained | Physical tests and capability-gated affordances |
| App Store readiness | B: platform constrained | Review manifests, entitlements, permissions and distribution requirements before submission |

Reliability, security, and input latency take precedence over visual polish and extras. No App Store submission, public server deployment, telemetry, service installation or account changes have occurred. Apple account changes and App Store submission remain outside the requested scope.
