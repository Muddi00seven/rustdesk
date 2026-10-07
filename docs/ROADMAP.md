# MacPilot milestone status

The complete requested scope is retained in `MACPILOT_REQUIREMENTS.md`. This status reflects demonstrated behavior, not planned functionality.

| Milestone | Work | Status / acceptance gate |
| --- | --- | --- |
| 0 | Audit, fork, pinned tools, unmodified Apple builds, baseline run | In progress; Xcode setup cleared, pinned tools installed, and baseline builds started. |
| 1 | Central branding and clean device dashboard | Pending milestone 0; no rebranding yet |
| 2 | Stable iPad-to-Mac session | Pending physical session validation |
| 3 | Touch/direct/relative pointer, mouse identity, scroll | Pending baseline and existing-input trace |
| 4 | Hardware keyboard and touch modifier/accessory behavior | Pending physical keyboard tests |
| 5 | Event-based AX editable context and iPad text-input bridge | Pending SDK validation, privacy review, native and physical tests |
| 6 | Reconnect state machine and network quality | Pending authenticated-session lifecycle trace and fault-injection tests |
| 7 | Unattended access and permission onboarding | Pending service, secret-storage, revocation, and permission checks |
| 8 | Multiple Macs and per-device preferences | Pending secure persistence and dashboard integration |
| 9 | Self-hosting | Pending configured rendezvous/relay integration validation |
| 10 | Production hardening, documentation, diagnostics and acceptance | Pending all preceding milestones and physical acceptance A–D |

After each milestone: build both Apple clients, run relevant tests, document actual results and limitations, and create a logical Git checkpoint. Do not create the baseline tag until milestone 0 succeeds. Features remain isolated and preserve the upstream path when disabled.

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

Reliability, security, and input latency take precedence over visual polish and extras. No App Store submission, public server deployment, telemetry, or account changes are authorized by this preparation milestone.
